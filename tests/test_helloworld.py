# app/src/tests/test_helloworld.py

from src.helloworld import hello_world

def test_hello_world():
    assert hello_world() == "Hello world"

