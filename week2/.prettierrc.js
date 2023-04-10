module.exports = {
  singleQuote: true,
  printWidth: 120,
  trailingComma: 'all',
  bracketSpacing: false,
  semi: false,
  overrides: [
    {
      files: '*.sol',
      options: {
        printWidth: 120,
        tabWidth: 4,
        useTabs: false,
        singleQuote: false,
        bracketSpacing: false,
        singleQuote: false,
        parser: 'solidity-parse',
      },
    },
  ],
  plugins: [require('prettier-plugin-solidity')],
}
