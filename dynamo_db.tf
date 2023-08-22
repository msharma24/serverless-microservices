#--------------------------------------------------------------
# aws_dynamodb_table
#--------------------------------------------------------------

resource "aws_dynamodb_table" "ecommerce_table" {
  name         = "EcommerceTable"
  billing_mode = "PAY_PER_REQUEST"

  hash_key  = "PK"
  range_key = "SK" #composite part key

  stream_enabled   = true
  stream_view_type = "NEW_IMAGE"


  attribute {
    name = "PK"
    type = "S"
  }


  attribute {
    name = "SK"
    type = "S"
  }

  attribute {
    name = "GSI1PK"
    type = "S"
  }

  attribute {
    name = "GSI1SK"
    type = "S"
  }

  global_secondary_index {
    name            = "GSI1"
    hash_key        = "GSI1PK"
    range_key       = "GSI1SK"
    projection_type = "ALL"
  }

}
