got() {
  if [ -n "$(go vet ./... 2>&1)" ]; then
    echo 'Vet errors'
    go vet ./...
    return 1
  fi
  if [ -n "$(gofmt -s -l .)" ]; then
    echo 'Fix formatting:'
    gofmt -s -l -d .
    return 1
  fi
  go test ./...
  if [ $? -ne 0 ]; then
    echo 'Test errors'
    return 1
  fi
  go run github.com/google/addlicense@v1.1.1 -check -s=only -ignore='bin/**' -ignore='**/.terraform.lock.hcl' -ignore='definitions/**' ** 
  if [ $? -ne 0 ]; then
    echo 'Licenses missing'
    return 1
  fi
  echo "Looks good"
}
gofix() {
  gofmt -s -w -l . && go run github.com/google/addlicense@v1.1.1 -s=only -ignore='bin/**' -ignore='**/.terraform.lock.hcl' -ignore='definitions/**' **
}

