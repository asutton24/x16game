import random

def deconstructu16(x):
    return [x % 256, x // 256]

class Rectangle:

    def __init__(self):
        self.x = 0
        self.y = 0
        self.width = 0
        self.height = 0

    def __str__(self):
        return str(self.x) + ' ' + str(self.width) + ' ' + str(self.y) + ' ' + str(self.height) + ' '
    
    def randomize(self):
        hori = random.randint(1, 65535)
        vert = random.randint(1, 65535)
        self.width = random.randint(1, hori)
        self.height = random.randint(1, vert)
        self.x = hori - self.width
        self.y = vert - self.height

    def collide(self, other):
        return self.x + self.width >= other.x and self.x <= other.x + other.width and self.y + self.height >= other.y and self.y <= other.y + other.height
    
    def getbytes(self):
        return deconstructu16(self.x) + deconstructu16(self.width) + deconstructu16(self.y) + deconstructu16(self.height)

r1 = Rectangle()
r2 = Rectangle()
data = []
for i in range(5):
    collision = False
    while not collision:
        r1.randomize()
        r2.randomize()
        collision = r1.collide(r2)
    print("{}{}".format(r1, r2))
    data += r1.getbytes() + r2.getbytes()
for i in range(5):
    collision = True
    while collision:
        r1.randomize()
        r2.randomize()
        collision = r1.collide(r2)
    print("{}{}".format(r1, r2))
    data += r1.getbytes() + r2.getbytes()

final = "dcb "

for i in data:
    final += "$" + f"{i:X}" + " "

print(final)
    