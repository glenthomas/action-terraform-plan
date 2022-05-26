# Github Action to Run Terraform Plan
[![Lint](https://github.com/Cazoo-uk/action-terraform-plan/actions/workflows/lint.yaml/badge.svg)](https://github.com/Cazoo-uk/action-terraform-plan/actions/workflows/lint.yaml) [![Test](https://github.com/Cazoo-uk/action-terraform-plan/actions/workflows/test.yaml/badge.svg)](https://github.com/Cazoo-uk/action-terraform-plan/actions/workflows/test.yaml) [![Release](https://github.com/Cazoo-uk/action-terraform-plan/actions/workflows/release.yaml/badge.svg)](https://github.com/Cazoo-uk/action-terraform-plan/actions/workflows/release.yaml)

This is an opinionated version of [dflook/terraform-plan](https://github.com/dflook/terraform-plan) action.

### Usage
```yaml
name: My Project

on: pull_request

permissions:
  contents: read       # Required for actions/checkout
  id-token: write      # Only required for AWS Authentication
  pull-requests: write # Required to post terraform plan in PR comment

jobs:
  terraform-plan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      # Authenticate to AWS if necessary
      - name: AWS Authentication
        uses: Cazoo-uk/action-aws-auth@v1
        with:
          account_id: '123456789012'
          role: plan

      # Run terraform plan
      - name: Terraform Format and Plan
        id: tf_plan
        uses: Cazoo-uk/action-terraform-plan@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }} # must be set for the plan to be added as PR comment, unless add_github_comment is "false"
        with:
          path: path/to/terraform/code
          
      # Read output from Terraform plan action
      - name: Check if terraform plan has changed
        run:  echo ${{ steps.tf_plan.outputs.changes }}
```

An example of a GHA workflow using this action to perform a Terraform deployment can be found in [example-terraform-workflow](https://github.com/Cazoo-uk/example-terraform-workflow).

### Defaults
| Parameters | Default Value  | Required | Description |
| :---   | :- | :-: | :- |
| path |  | ✅ | Path to the Terraform files directory  |
| label |  | ❌ | A friendly name for the plan (if specified, needs to match the label used in the apply action)  |
| backend_config_file |  | ❌ | Backend config file for terraform |
| var_file |  | ❌ | List of tfvars files to use |
| add_github_comment | "true" | ❌ | Write changes generated by plan to the PR. "true", "false" or "changes-only"  |

### Outputs
Reference can be found [here](https://github.com/dflook/terraform-plan#outputs)

### Accessing remote modules
Remote terraform modules can be accessed using `git+ssh://` protocol which requires private SSH key authorised to access that repository where the module is located. [dflook/terraform-plan](https://github.com/dflook/terraform-plan) supports this with an environment variable `TERRAFORM_SSH_KEY`. We can pass this as:
```yaml
- name: Terraform Format and Plan
  uses: Cazoo-uk/action-terraform-plan@v1
  env:
    TERRAFORM_SSH_KEY: ${{ secrets.CAZOO_READ_REPO_KEY }}
  with:
    path: path/to/terraform/code
```

### Example
The use of this shared Composite Action is demonstrated in the [example-terraform-workflow](https://github.com/Cazoo-uk/example-terraform-workflow) repository.
