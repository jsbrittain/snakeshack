def get_address_filename():
    address = config["address"]
    return os.path.basename(address).split("?")[0]


def strip_address_ext():
    return os.path.splitext(get_address_filename())[0]


def get_address_ext():
    return os.path.splitext(get_address_filename())[1]


def get_infile_filename():
    address = config["infile"]
    return os.path.basename(address).split("?")[0]


def strip_infile_ext():
    return os.path.splitext(get_infile_filename())[0]
