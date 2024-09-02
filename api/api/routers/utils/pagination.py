def last_page_index(page_size: int, document_count: int):
    """
    Determine last page index based on requested page size and document
    count.
    """
    if document_count == 0:
        return 0
    idx = document_count // page_size
    if document_count % page_size == 0:
        # No remainder. Page index is reduced by one due to zero-indexing.
        idx -= 1
    return idx


def link_header(
        page: int,
        page_size: int,
        document_count: int,
        url: str
):
    """
    Create an [RFC5988](https://datatracker.ietf.org/doc/html/rfc5988#section-5)
    compliant entry for the `link` header`.

    Parameters
    ----------
    page: int
        The requested page
    page_size: int
        The requested page size
    document_count: int
        The number of existing documents for the requested resource
    url: str
        The requested URl

    Returns
    -------
    str
        Entry to place in the `link` header field.
    """  # noqa: E501
    link_header = ""
    if document_count == 0:
        # No data to navigate
        return link_header

    requested_page_query = f"page={page}"
    requested_page_size_query = f"page_size={page_size}"

    # Requested url might not contain a (complete) query string if default
    # params were used. Add pagination params for later replacements.
    if "?" not in url:
        url += f"?{requested_page_query}&{requested_page_size_query}"
    else:
        (url_without_query, query) = tuple(url.split("?"))
        if requested_page_query not in query:
            query += f"&{requested_page_query}"
        if requested_page_size_query not in query:
            query += f"&{requested_page_size_query}"
        url = url_without_query + "?" + query.strip("&")

    # Pages are zero-indexed
    first_page = 0
    # Determine last page
    last_page = last_page_index(
        page_size=page_size, document_count=document_count
    )

    # If previous page exists add a link
    prev_page = page - 1
    if prev_page >= first_page:
        prev_page_link = url.replace(
            requested_page_query, f"page={prev_page}"
        )
        link_header += f'<{prev_page_link}>; rel="prev", '

    # If next page exists add a link
    next_page = page + 1
    if next_page <= last_page:
        next_page_link = url.replace(
            requested_page_query, f"page={next_page}"
        )
        link_header += f'<{next_page_link}>; rel="next", '

    # Add link to first page
    first_page_link = url.replace(
        requested_page_query, f"page={first_page}"
    )
    link_header += f'<{first_page_link}>; rel="first", '

    # Add link to last page
    last_page_link = url.replace(
        requested_page_query, f"page={last_page}"
    )
    link_header += f'<{last_page_link}>; rel="last"'

    return link_header
