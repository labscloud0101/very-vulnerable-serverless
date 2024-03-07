#!/bin/bash
unamestr=$(uname)
if ! [ -x "$(command -v python3)" ]; then
  echo '[ERROR] python3 is not installed.' >&2
  exit 1
fi

if ! [ -x "$(command -v npm)" ]; then
  echo '[ERROR] npm is not installed.' >&2
  exit 1
fi

echo "Serverless Attack Lab"
sed -i'' -e "s/myrandombucket/$(uuidgen | tr '[:upper:]' '[:lower:]')/g" serverless.yml
sed -i 's/us-west-2/us-east-1/g' serverless.yml
echo '[INSTALL] Found Python3'
python3 -m pip -V
if [ $? -eq 0 ]; then
echo '[INSTALL] Found pip'
if [[ $unamestr == 'Darwin' ]]; then
    python3 -m pip install --no-cache-dir --upgrade pip
else
    python3 -m pip install --no-cache-dir --upgrade pip --user
fi
else
echo '[ERROR] python3-pip not installed'
exit 1
fi
echo '[INSTALL] Using python virtualenv'
rm -rf ./venv
python3 -m venv ./venv
if [ $? -eq 0 ]; then
    echo '[INSTALL] Activating virtualenv'
    source venv/bin/activate
    pip install --upgrade pip wheel
else
    echo '[ERROR] Failed to create virtualenv'
    exit 1
fi
echo '[INSTALL] Installing Requirements'
pip install --no-cache-dir --use-deprecated=legacy-resolver -r requirements.txt
npm install fast-xml-parser
npm install -g serverless
sls plugin install -n serverless-python-requirements && sls plugin install -n serverless-s3-deploy && sls plugin install -n serverless-wsgi
sls deploy
