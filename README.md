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
      - uses: actions/checkout@v3

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
          backend_config: key="my-application.tfstate"
          variables: |
            image_id = "782jskvgy3290iuvskjnf"
            availability_zone_names = [
              "us-east-1a",
              "us-west-1c",
            ]

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
| backend_config |  | ❌ | List of terraform backend config values, one per line |
| var_file |  | ❌ | List of tfvars files to use |
| variables |  | ❌ | Variables to set for the terraform plan |
| add_github_comment | "true" | ❌ | Write changes generated by plan to the PR. "true", "false" or "changes-only"  |
| target |  | ❌ | List of resources to apply, one per line. The plan will be limited to these resources and their dependencies.  |

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

### Target Resources

You can use the `target` parameter to target specific resources, modules, or collections of resources.
Targeting individual resources can be useful for troubleshooting errors, but should not be part of your normal workflow.
More info in the [Official Documentation](https://developer.hashicorp.com/terraform/tutorials/state/resource-targeting).

```yaml
- name: Terraform Format and Plan
  id: tf_plan
  uses: Cazoo-uk/action-terraform-plan@v1
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }} # must be set for the plan to be added as PR comment, unless add_github_comment is "false"
  with:
    path: path/to/terraform/code
    target: |
      resource_type_1.resource_name_1
      resource_type_2.resource_name_2
```