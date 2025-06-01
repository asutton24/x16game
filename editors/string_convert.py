string = input("Enter ascii: ")
string = string.upper()
ret = "dcb "
for c in string:
    ret += "$" + format(ord(c), 'x').upper() + " "
print(";" + string + "\n" + ret)