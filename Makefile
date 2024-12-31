.PHONY: lint setup

setup:
	poetry install

lint:
	poetry run yamllint .
