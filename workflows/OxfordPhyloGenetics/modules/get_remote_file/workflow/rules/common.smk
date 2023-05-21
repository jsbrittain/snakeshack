def get_address_filename():
    address = config["address"]
    return os.path.basename(address).split("?")[0]


def strip_address_ext():
    return os.path.splitext(get_address_filename())[0]


def get_address_ext():
    return os.path.splitext(get_address_filename())[1]


def get_filename_filename():
    address = config["output_filename"]
    return os.path.basename(address).split("?")[0]


def strip_filename_ext():
    return os.path.splitext(get_filename_filename())[0]
