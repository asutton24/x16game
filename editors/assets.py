import os

def get_level_name(id):
    return "LVL" + f"{id:02X}" + ".BIN"

def pack_levels():
    digits = "0123456789ABCDEF"
    nums_to_check = []
    file_data = b''
    for name in os.listdir("Levels"):
        if name[0:3] == "LVL" and name[5:] == ".BIN" and name[3] in digits and name[4] in digits: nums_to_check.append(int(name[3:5], 16))
    nums_to_check.sort()
    for n in nums_to_check:
        with open("Levels/" + get_level_name(n), "rb") as file:
            level_data = file.read()
            file_data += n.to_bytes(1, byteorder="little") + len(level_data).to_bytes(2, byteorder="little") + level_data
            file.close()
    with open("Assetfile", "wb") as file:
        file.write(file_data)
        file.close()

def unpack_levels():
    with open("Assetfile", "rb") as file:
        level_data = file.read(1)
        while level_data:
            level_id = int.from_bytes(level_data, "little")
            level_length = int.from_bytes(file.read(2), "little")
            print(level_id, level_length)
            with open("Levels/" + get_level_name(level_id), "wb") as f:
                f.write(file.read(level_length))
                f.close()
            level_data = file.read(1)
        file.close()

def main():
    mode = "x"
    while mode not in "pu":
        mode = input("(p)ack assets\n(u)npack assets\n").lower()
    if mode == "p": pack_levels()
    else: unpack_levels()

main()
