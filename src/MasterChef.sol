// SPDX-License-Identifier: MIT
pragma solidity ~0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MasterChef is Ownable {
    struct UserInfo {
        // How many LP tokens the user has provided.
        uint256 amount;
        // Reward debt.
        uint256 rewardDebt;
    }

    struct PoolInfo {
        // Address of LP token contract.
        IERC20 lpToken;
        // lp balance
        uint256 balance;
        // How many allocation points assigned to this pool. EGGs to distribute per block.
        uint128 allocPoint;
        // Last block number that EGGs distribution occurs.
        uint256 lastRewardBlock;
        // Accumulated EGGs per share, times 1e12.
        uint256 accEggPerShare;
        // The block number when EGG mining starts.
        uint256 startBlock;
    }

    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    IERC20 public eggToken;
    // EGG tokens created per block.
    uint128 public eggPerBlock;
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint128 public totalAllocPoint;
    // foundationBalance
    uint256 public foundationBalance;
    // foundation deduct a percentage
    uint64 public foundationProportion;
    // foundation address
    address public foundation;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event Harvest(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    // View function to see pending EGGs on frontend.
    function pendingEgg(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accEggPerShare = pool.accEggPerShare;
        uint256 lpSupply = pool.balance;
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = block.number - pool.lastRewardBlock;
            uint256 eggReward = (multiplier * eggPerBlock * pool.allocPoint) / totalAllocPoint;
            accEggPerShare = accEggPerShare + (eggReward * 1e12) / lpSupply;
        }
        return (user.amount * accEggPerShare) / 1e12 - user.rewardDebt;
    }

    function setRunEnv(
        IERC20 _eggAddress,
        uint128 _eggPerBlock,
        address _foundation,
        uint64 _foundationProportion
    ) external onlyOwner {
        eggToken = _eggAddress;
        eggPerBlock = _eggPerBlock;
        foundation = _foundation;
        foundationProportion = _foundationProportion;
    }

    function add(uint128 _allocPoint, IERC20 _lpToken, uint256 _startBlock, bool _withUpdate) external onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > _startBlock ? block.number : _startBlock;
        totalAllocPoint = totalAllocPoint + _allocPoint;
        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                balance: 0,
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                accEggPerShare: 0,
                startBlock: _startBlock
            })
        );
    }

    function set(uint256 _pid, uint128 _allocPoint, bool _withUpdate) external onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint128 prevAllocPoint = poolInfo[_pid].allocPoint;
        poolInfo[_pid].allocPoint = _allocPoint;

        if (prevAllocPoint != _allocPoint) {
            totalAllocPoint = totalAllocPoint - prevAllocPoint + _allocPoint;
        }
    }

    // Deposit LP tokens to MasterChef for EGG allocation.
    function deposit(uint256 _pid, uint256 _amount) external {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = (user.amount * pool.accEggPerShare) / 1e12 - user.rewardDebt;
            if (pending > 0) {
                eggToken.transfer(msg.sender, pending);
            }
        }
        if (_amount > 0) {
            pool.lpToken.transferFrom(address(msg.sender), address(this), _amount);
            pool.balance += _amount;
            user.amount += _amount;
        }
        user.rewardDebt = (user.amount * pool.accEggPerShare) / 1e12;
        emit Deposit(msg.sender, _pid, _amount);
    }

    // Withdraw LP tokens from MasterChef.
    function withdraw(uint256 _pid, uint256 _amount) external {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");

        updatePool(_pid);
        uint256 pending = (user.amount * pool.accEggPerShare) / 1e12 - user.rewardDebt;
        if (pending > 0) {
            eggToken.transfer(msg.sender, pending);
        }
        if (_amount > 0) {
            user.amount -= _amount;
            pool.balance -= _amount;
            pool.lpToken.transfer(address(msg.sender), _amount);
        }
        user.rewardDebt = (user.amount * pool.accEggPerShare) / 1e12;
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function harvest(uint256 _pid) external {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 accumulated = (user.amount * pool.accEggPerShare) / 1e12;
            uint256 pending = accumulated - user.rewardDebt;
            if (pending > 0) {
                eggToken.transfer(msg.sender, pending);
            }
            user.rewardDebt = accumulated;
            emit Harvest(msg.sender, _pid, pending);
        }
    }

    // update foundation address
    function updateFoundation(address _foundation) external {
        require(msg.sender == foundation, "only foundation");
        foundation = _foundation;
    }

    // withdraw foundation balance
    function withdrawFoundation() external {
        eggToken.transfer(foundation, foundationBalance);
        foundationBalance = 0;
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) external {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        pool.balance -= user.amount;
        pool.lpToken.transfer(address(msg.sender), user.amount);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.balance;
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = block.number - pool.lastRewardBlock;
        uint256 eggReward = (multiplier * eggPerBlock * pool.allocPoint) / totalAllocPoint;
        pool.accEggPerShare = pool.accEggPerShare + (eggReward * 1e12) / lpSupply;
        pool.lastRewardBlock = block.number;
        foundationBalance += eggReward / foundationProportion;
    }
}
