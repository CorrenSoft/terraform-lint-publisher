
# terraform-lint-publisher

Terraform Lint Publisher is a GitHub Action that runs **[TFLint](https://github.com/terraform-linters/tflint)** with opinionated defaults, interprets the results, and publishes them using **[github-content-publisher](https://github.com/CorrenSoft/github-content-publisher)**.

## Features
- Runs TFLint safely without failing immediately (unless TFLint itself fails to run)
- Produces a single logical state: success or failure
- Publishes results to:
  - Job Summary
  - Pull Request comments
  - Check Runs

## Inputs
See `action.yml` for the complete list. Highlights:
- `working_directory`
- `minimum_severity`
- `publish_summary | publish_pr | publish_check_run`
- `fail_on_issues`

## Example
```yaml
- uses: CorrenSoft/terraform-lint-publisher@v0.1.0
  with:
    working_directory: ./tests/terraform/basic
    minimum_severity: error
    publish_pr: on-failure
```

## Disclaimers
- This project is **not affiliated with or endorsed by HashiCorp**.
- Terraform is a trademark of HashiCorp, Inc.
- This action uses the open-source tool **TFLint**.
