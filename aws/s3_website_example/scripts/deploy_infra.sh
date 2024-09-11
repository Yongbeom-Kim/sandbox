#!/bin/sh

export $(cat ./.env | xargs)
cd tf
tofu init
tofu plan
tofu apply