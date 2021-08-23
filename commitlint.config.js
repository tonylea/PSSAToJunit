const conventionalCommit = require("./conventionalCommit.json");

const typesEnum = Object.keys(conventionalCommit.types);
const scopesEnum = Object.keys(conventionalCommit.scopes);

module.exports = {
  extends: ["@commitlint/config-conventional"],
  rules: {
    "type-enum": [2, "always", typesEnum],
    "scope-case": [2, "always", ["camel-case"]],
    "scope-enum": [2, "always", scopesEnum],
    "scope-empty": [0, "always"],
    "body-full-stop": [2, "always", "."],
    "body-case": [2, "always", "sentence-case"]
  },
};