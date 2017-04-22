import pytest
import sys
import os


@pytest.fixture(scope='session', autouse=True)
def import_parent_dir():
    sys.path.append(os.path.abspath(os.path.join(
        os.path.dirname(__file__), os.path.pardir)))
    yield
