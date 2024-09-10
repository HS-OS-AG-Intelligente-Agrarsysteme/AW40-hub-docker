import pytest

from api.routers.utils.pagination import last_page_index, link_header


@pytest.mark.parametrize(
    "page_size,document_count,expected_index",
    [
        (1, 0, 0),
        (1, 1, 0),
        (1, 10, 9),
        (2, 10, 4),
        (2, 11, 5)
    ]
)
def test_last_page_index(page_size, document_count, expected_index):
    assert last_page_index(
        page_size=page_size, document_count=document_count
    ) == expected_index


@pytest.mark.parametrize("page_size", [1.0, "1"], ids=["float", "str"])
def test_last_page_index_invalid_page_size_type(page_size):
    with pytest.raises(TypeError):
        last_page_index(page_size=page_size, document_count=0)


@pytest.mark.parametrize("document_count", [1.0, "1"], ids=["float", "str"])
def test_last_page_index_invalid_document_count_type(document_count):
    with pytest.raises(TypeError):
        last_page_index(page_size=1, document_count=document_count)


@pytest.mark.parametrize("page_size", [-1, 0])
def test_last_page_index_invalid_page_size_value(page_size):
    with pytest.raises(ValueError):
        last_page_index(page_size=page_size, document_count=0)


def test_last_page_index_invalid_document_count_value():
    with pytest.raises(ValueError):
        last_page_index(page_size=1, document_count=-1)


@pytest.mark.parametrize("page", [1.0, "1"], ids=["float", "str"])
def test_link_header_invalid_page_type(page):
    with pytest.raises(TypeError):
        link_header(page=page, page_size=1, document_count=0, url="http://")


@pytest.mark.parametrize("page_size", [1.0, "1"], ids=["float", "str"])
def test_link_header_invalid_page_size_type(page_size):
    with pytest.raises(TypeError):
        link_header(
            page=0, page_size=page_size, document_count=0, url="http://"
        )


@pytest.mark.parametrize("document_count", [1.0, "1"], ids=["float", "str"])
def test_link_header_invalid_document_count_type(document_count):
    with pytest.raises(TypeError):
        link_header(
            page=0, page_size=1, document_count=document_count, url="http://"
        )


def test_link_header_invalid_page_value():
    with pytest.raises(ValueError):
        link_header(page=-1, page_size=1, document_count=0, url="http://")


@pytest.mark.parametrize("page_size", [-1, 0])
def test_link_header_invalid_page_size_value(page_size):
    with pytest.raises(ValueError):
        link_header(
            page=0, page_size=page_size, document_count=0, url="http://"
        )


def test_link_header_invalid_document_count_value():
    with pytest.raises(ValueError):
        link_header(page=0, page_size=1, document_count=-1, url="http://")
