# Template repo for IBM Cloud Terraform projects

## pre-commit hooks:

The following pre-commit hooks are defined in the `.pre-commit-config.yaml` file:

 - terraform_fmt: Syntax checking for Terraform
 - detect-secrets: Ensure we don't commit anything sensitive
 - terraform_docs: Generate a INFO.md for the Terraform resources 
 
**Install pre-commit:**

```
$ pip install pre-commit
```

**Install hooks:**

```
$ pre-commit install
```

## detect-secrets: 

To add new secrets to the existing baseline, run the following command:

```shell
$ detect-secrets scan --baseline .secrets.baseline
```

This will rescan your codebase, and:

- Update/upgrade your baseline to be compatible with the latest version,
- Add any new secrets it finds to your baseline, and remove any secrets no longer in your codebase
- Preserve any labelled secrets you have.
