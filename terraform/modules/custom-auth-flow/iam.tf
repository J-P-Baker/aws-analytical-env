resource aws_iam_role role_for_lambda_create_auth_challenge {
  name               = "Role-Lambda-Create-Auth_Challenge"
  assume_role_policy = data.aws_iam_policy_document.assume_role_lambda.json
}
resource aws_iam_role role_for_lambda_define_auth_challenge {
  name               = "Role-Lambda-Define-Auth_Challenge"
  assume_role_policy = data.aws_iam_policy_document.assume_role_lambda.json
}
resource aws_iam_role role_for_lambda_verify_auth_challenge {
  name               = "Role-Lambda-Verify-Auth_Challenge"
  assume_role_policy = data.aws_iam_policy_document.assume_role_lambda.json
}

resource "aws_iam_role" "role_for_lambda_pre_token_generation" {
  name               = "Role-Lambda-Pre-Token-Generation"
  assume_role_policy = data.aws_iam_policy_document.assume_role_lambda.json
}

data aws_iam_policy_document assume_role_lambda {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource aws_iam_role_policy cognito_create_auth_policy {
  policy = data.aws_iam_policy_document.cognito_create_auth_policy_document.json
  role   = aws_iam_role.role_for_lambda_create_auth_challenge.name
}

// Work around for AWS SMS / SNS - SEE - https://stackoverflow.com/questions/38871201/authorization-when-sending-a-text-message-using-amazonsnsclient
data aws_iam_policy_document cognito_create_auth_policy_document {
  statement {
    effect = "Allow"
    actions = [
      "sns:Publish"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Deny"
    actions = [
      "sns:Publish"
    ]
    resources = ["arn:aws:sns:*:*:*"]
  }
}

resource "aws_iam_role_policy_attachment" "cognito_create_challenge_basic_execution" {
  role       = aws_iam_role.role_for_lambda_create_auth_challenge.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "cognito_verify_challenge_basic_execution" {
  role       = aws_iam_role.role_for_lambda_verify_auth_challenge.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "cognito_define_challenge_trigger_basic_execution" {
  role       = aws_iam_role.role_for_lambda_define_auth_challenge.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "cognito_pre_token_generation_basic_execution" {
  role       = aws_iam_role.role_for_lambda_pre_token_generation.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource aws_iam_role_policy cognito_define_auth_policy {
  policy = data.aws_iam_policy_document.cognito_define_auth_policy.json
  role   = aws_iam_role.role_for_lambda_define_auth_challenge.name
}

data aws_iam_policy_document cognito_define_auth_policy {
  statement {
    effect = "Allow"
    actions = [
      "cognito-idp:AdminGetUser",
    ]
    resources = [
      var.cognito_user_pool_arn
    ]
  }
}
