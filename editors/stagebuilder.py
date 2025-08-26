def build_stage(low, length, id):
    stage = b''
    for i in range(low, low + length):
        with open("Levels/LVL" + f"{i:02X}" + ".BIN", "rb") as file:
            stage += file.read().ljust(512, b'\x00')
            file.close()
    with open("STG" + f"{id:X}" + ".BIN", "wb") as file:
        file.write(stage)
        file.write(b'\xFF\xFF')
        file.close()

build_stage(0, 10, 0)
build_stage(10, 9, 1)
build_stage(19, 9, 2)
build_stage(28, 6, 3)
# low = int(input("enter begining of stage"))
# length = int(input("enter length of stage"))
# id = int(input("enter stage id")) % 16

