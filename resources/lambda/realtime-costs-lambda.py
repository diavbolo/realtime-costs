import os
import json
import boto3
import datetime

class DynamoDB:

  def __init__(self):
    self.client = boto3.client('dynamodb')
    self.response={}

  def insert_record(self, table, item):
    self.response = self.client.put_item(
      TableName=table,
      Item=item
    )

  def update_status(self, table, data):
    try:
      self.response = self.client.update_item(
        TableName=table,  
        Key={
          'account_id': {
            'S': data['account_id']
          }
        },
        UpdateExpression="set status = :status",
        ExpressionAttributeValues={
          ':status': {
            'S': data['action']
          }
        },
        ReturnValues="UPDATED_NEW"
      )

    except:
      # Execute this block in case the record already exists
      if data['action'] == 'add':
        status = "on"
      else:
        status = "off"

      item={
        'account_id': {
          'S': data['account_id']
        },
        'status': {
          'S': status
        }
      }
      self.response = self.insert_record(table=os.environ.get('status'), item=item)

def handler(event, context):
  try:

    dynamodb = DynamoDB()

    data = json.loads(event["body"])

    item={
      'timestamp': {
        'S': str(datetime.datetime.now())
      },
      'account_id': {
        'S': data['account_id']
      },
      'user': {
        'S': data['user']
      },
      'email': {
        'S': data['email']
      },
      'action': {
        'S': data['action']
      }
    }
    dynamodb.insert_record(table=os.environ.get('logging'), item=item)
    dynamodb.update_status(table=os.environ.get('status'), data=data)

    response = {
        'statusCode': 200,
        'body': 'successfully created item!',
        'headers': {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*'
        },
    }

  except:
    response = {
        'statusCode': 400,
        'body': 'an error happened while creating the item!',
        'headers': {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*'
        },
    }
  
  return response