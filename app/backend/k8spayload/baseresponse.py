class BaseResponse:
    """Base response object

    To be used for what to send back to the HTTP caller
    """

    def __init__(self):
        self.menu = None
        self.body = None

    def add_menu(self, title, link):
        """Add item to menu response property
        Parameters
        ----------
        title : str
            Title to display for menu item
        link : str
            Link path
        """

        if self.menu:
            self.menu.append({
                'title': title,
                'link': link
            })
        else:
            self.menu = [{
                'title': title,
                'link': link
            }]

    def __iter__(self):
        """Generate the response object items"""

        yield 'menu', self.menu
        yield 'body', self.body
