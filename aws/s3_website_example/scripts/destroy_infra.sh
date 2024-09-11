#!/bin/sh

export $(cat ./.env | xargs)
cd tf
tofu destroy