
# Retrieve the current AWS account information. Used to dynamically build the KMS key policy.
data "aws_caller_identity" "current" {}


# Build the KMS key policy. Grants the account root full control of the key.
data "aws_iam_policy_document" "this" {

  statement {
    sid    = "EnableRootPermissions"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }
    
    actions = [
      "kms:*"
    ]

    resources = [
      "*"
    ]
  }
}


# Attach the policy to the KMS key. Defines who can administer and use the key.
#--------------------------------------------------------------------------------
resource "aws_kms_key_policy" "this" {

  key_id = aws_kms_key.kms_key.id
  policy = data.aws_iam_policy_document.this.json

}