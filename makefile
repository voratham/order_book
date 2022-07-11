unit-test:
	mix test

test-coverage:
	MIX_ENV=test mix coveralls.html && open ./cover/excoveralls.html