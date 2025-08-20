import pygame
from sprite import Text, Sprite

color_list = [((0, 0, 0), 0), ((255, 255, 255), 1), ((51, 255, 102), 136), ((0, 255, 255), 171), ((187, 119, 255), 213)]

#entity definitions in ref.txt [type, param1, param2]

entity_ref = [[1, 0, 0], [4, 0, 0], [5, 0, 0], [6, 0, 0], [7, 0, 0], [8, 0, 0], [9, 0, 0], [10, 0, 0], [11, 0, 0]]

index_to_frame = {1:1, 4:13, 5:12, 6:14, 7:16, 8:18, 9:19, 10:21, 11:22}

def is_rectangle_redundant(index, rects):
    point_in_rectangle = lambda rt, x, y : (rt[2][0] <= x <= rt[2][0] + rt[2][2]) and (rt[2][1] <= y <= rt[2][1] + rt[2][3])
    counter = 0
    for r in rects:
        if index == counter:
            counter += 1
            continue
        if point_in_rectangle(r, rects[index][2][0], rects[index][2][1]) and point_in_rectangle(r, rects[index][2][0] + rects[index][2][2], rects[index][2][1] + rects[index][2][3]):
            return True
        counter += 1
    return False

class Editor:

    def __init__(self, num, scr):
        self.rectangles = []
        self.enemies = []
        self.cur_color = 0
        self.cur_border = 5
        self.snap_to = 16
        self.file_id = num
        self.cur_enemy = 0
        self.screen = scr
        self.edit_mode = "playfield"
    
    def add_rectangle(self, x1, y1, x2, y2):
        x1 = x1 // self.snap_to * self.snap_to
        x2 = x2 // self.snap_to * self.snap_to + self.snap_to
        y1 = y1 // self.snap_to * self.snap_to
        y2 = y2 // self.snap_to * self.snap_to + self.snap_to
        if x1 == x2 or y1 == y2: return
        if x2 < x1: x1, x2 = x2, x1
        if y2 < y1: y1, y2 = y2, y1
        if (self.cur_border > 0 and x2 - x1 - 2 * self.cur_border <= 0 and y2 - y1 - 2 * self.cur_border <= 0): return
        self.rectangles.append((self.cur_color, self.cur_border, [x1, y1, x2 - x1, y2 - y1]))
    
    def remove_rectangle(self, x, y):
        tracker = 0
        indices_to_remove = []
        for _, _, lst in self.rectangles:
            if lst[0] <= x <= lst[0] + lst[2] and lst[1] <= y <= lst[1] + lst[3]: indices_to_remove.append(tracker)
            tracker += 1
        indices_to_remove.reverse()
        for i in indices_to_remove:
            del self.rectangles[i]

    def add_enemy(self, x, y):
        x = x // self.snap_to * self.snap_to
        y = y // self.snap_to * self.snap_to
        entity_type = entity_ref[self.cur_enemy][0]
        if entity_type == 1 or entity_type == 4:
            for i in range(len(self.enemies)):
                if self.enemies[i][0] == entity_ref[self.cur_enemy][0]:
                    self.enemies[i][1] = x
                    self.enemies[i][2] = y
                    return
        if entity_type == 7:
            add_drone(self, x, y)
            return
        elif entity_type == 8:
            add_turret(self, x, y)
            return
        self.enemies.append([entity_ref[self.cur_enemy][0], x, y, entity_ref[self.cur_enemy][1], entity_ref[self.cur_enemy][2]])
    
    def remove_enemy(self, x, y):
        tracker = 0
        indices_to_remove = []
        for e in self.enemies:
            if 0 <= x - e[1] <= 15 and 0 <= y - e[2] <= 15: indices_to_remove.append(tracker)
            tracker += 1
        indices_to_remove.reverse()
        for i in indices_to_remove:
            del self.enemies[i]
            
    def save_to_file(self):
        if self.file_id == -1:
            return -1
        int_16 = lambda x : [(x % 65536) % 256, (x % 65536) // 256]
        int_to_fixed = lambda x : [((x * 4) % 65536) % 256, ((x * 4) % 65536) // 256]
        header = [0] * 8
        playfield = []
        solid_colliders = []
        enemies = []
        extras = []
        player_pos = []
        exit_pos = []
        counter = 0
        redundant = False
        for r in self.rectangles:
            playfield.append(color_list[r[0]][1])
            redundant = is_rectangle_redundant(counter, self.rectangles)
            for i in range(4):
                playfield += int_16(r[2][i])
                if not redundant:
                    solid_colliders += int_to_fixed(r[2][i])
            if r[1] > 0:
                playfield.append(0)
                playfield += int_16(r[2][0] + r[1]) + int_16(r[2][1] + r[1]) + int_16(r[2][2] - 2 * r[1]) + int_16(r[2][3] - 2 * r[1])
            counter += 1
        playfield = [len(playfield) // 9] + [0] + playfield
        solid_colliders = [len(solid_colliders) // 8] + solid_colliders
        for e in self.enemies:
            if e[0] == 1:
                player_pos = int_to_fixed(e[1]) + int_to_fixed(e[2])
            elif e[0] == 4:
                exit_pos = int_to_fixed(e[1]) + int_to_fixed(e[2])
            else:
                enemies.append(e[0])
                for i in range(4):
                    if (i < 2): enemies += int_to_fixed(e[i + 1])
                    else: enemies += int_16(e[i + 1])
        enemies = [len(enemies) // 9] + enemies
        if playfield == []: playfield = [0]
        if solid_colliders == []: solid_colliders = [0]
        if enemies == []: enemies = [0]
        extras = player_pos + exit_pos 
        if extras == []: extras = [0]
        header[0] = 8
        header[2] = (len(playfield) + 8) % 256
        header[3] = (len(playfield) + 8) // 256
        header[4] = (len(solid_colliders) + len(playfield) + 8) % 256
        header[5] = (len(solid_colliders) + len(playfield) + 8) // 256
        header[6] = (len(solid_colliders) + len(playfield) + len(enemies) + 8) % 256
        header[7] = (len(solid_colliders) + len(playfield) + len(enemies) + 8) // 256
        #print(header + playfield + solid_colliders + enemies + extras)
        full_file = bytes(header + playfield + solid_colliders + enemies + extras)
        if len(full_file) > 512: return -1
        with open("Levels/" + "LVL{}.BIN".format(hex(self.file_id)[2:].zfill(2)).upper(), "wb") as file:
            file.write(full_file)
            file.close()
        print("File saved!")
        return 0                   
            
    
def draw_from_editor(edit):
    colors = [(100, 100, 100), (125, 125, 125)]
    col_index = 0
    edit.screen.fill((0, 0, 0))
    for i in range(240 // edit.snap_to):
        for j in range(320 // edit.snap_to):
            pygame.draw.rect(edit.screen, colors[col_index], [2 * j * edit.snap_to, 2 * i * edit.snap_to, 2 * edit.snap_to, 2 * edit.snap_to])
            col_index = (col_index + 1) % 2
        col_index = (col_index + 1) % 2
    for r in edit.rectangles:
        pygame.draw.rect(edit.screen, color_list[r[0]][0], [2 * r[2][0], 2 * r[2][1], 2 * r[2][2], 2 * r[2][3]])
        if (r[1] > 0 and r[2][2] - 2 * r[1] > 0 and r[2][3] - 2 * r[1] > 0):
            pygame.draw.rect(edit.screen, (0, 0, 0), [2 * (r[2][0] + r[1]), 2 * (r[2][1] + r[1]), 2 * (r[2][2] - 2 * r[1]), 2 * (r[2][3] - 2 * r[1])])
    drawSpr = Sprite("spritesheet.spr", 0, 0, (255, 255, 255), -1, 2, edit.screen)
    for e in edit.enemies:
        drawSpr.updateFrame(index_to_frame[e[0]])
        drawSpr.updatePos(e[1] * 2, e[2] * 2)
        drawSpr.update()
    if edit.edit_mode == "playfield":
        t = Text("Color-", 20, 500, (255, 255, 255), 2, edit.screen)
        t.update()
        pygame.draw.rect(edit.screen, color_list[edit.cur_color][0], [130, 500, 16, 16])
    elif edit.edit_mode == "enemies":
        t = Text("Enemy-", 20, 500, (255, 255, 255), 2, edit.screen)
        t.update()
        s = Sprite("spritesheet.spr", 130, 500, (255, 255, 255), -1, 1, edit.screen)
        s.updateFrame(index_to_frame[entity_ref[edit.cur_enemy][0]])
        s.update()
    t = Text("Level- {}".format(edit.file_id), 20, 540, (255, 255, 255), 2, edit.screen)
    t.update()

    
def query(qtype, prompt, edit):
    if qtype == None: return None
    return_val = 0
    while True:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                return -1
            if event.type == pygame.MOUSEBUTTONDOWN:
                if event.pos[1] < 480 and qtype == "position":
                    return [event.pos[0] // 2, event.pos[1] // 2]
            if event.type == pygame.KEYDOWN:
                if pygame.K_a <= event.key <= pygame.K_z and qtype == "letter":
                    return chr(event.key)
                elif pygame.K_0 <= event.key <= pygame.K_9 and qtype == "number":
                    return_val = return_val * 10 + event.key - pygame.K_0
                elif event.key == pygame.K_BACKSPACE and qtype == "number":
                    return_val = return_val // 10
                elif event.key == pygame.K_RETURN and qtype == "number":
                    return return_val
        draw_from_editor(edit)
        if prompt: Text(prompt, 300, 500, (255, 255, 255), 2, edit.screen).update()
        if qtype == "number": Text(f"{return_val}", 300, 540, (255, 255, 255), 2, edit.screen).update()
        pygame.display.update()

def add_drone(edit, x, y):
    newX = -1
    newY = -1
    while newX != x and newY != y:
        newX, newY = query("position", "Choose endpoint", edit)
        newX = newX // edit.snap_to * edit.snap_to
        newY = newY // edit.snap_to * edit.snap_to
    direction = 0
    lifetime = 0
    if x == newX:
        direction += 256
        lifetime = round(abs(newY - y) / 1.75)
        if newY - y < 0: direction += 1
    else:
        lifetime = round(abs(newX - x) / 1.75)
        if newX - x < 0: direction += 1
    edit.enemies.append([7, x, y, lifetime, direction])
    return

def add_turret(edit, x, y):
    xVal = x
    while xVal == x:
        xVal = query("position", "Choose direction", edit)[0]
    if xVal < x: direction = 0
    else: direction = 1
    time = 0
    while 0 == time or time > 255:
        time = query("number", "Frames between shots", edit)
    edit.enemies.append([8, x, y, direction, time])

def main():
    pygame.init()
    screen = pygame.display.set_mode((640, 640))
    edit = Editor(0, screen)
    edit.cur_color = 1
    running = True
    active_points = []
    appending_to_level = False
    while running:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
            elif event.type == pygame.MOUSEBUTTONDOWN:
                if event.pos[1] < 480 and edit.edit_mode == "playfield":
                    if event.button == 1:
                        active_points.append(event.pos)
                        if len(active_points) == 2:
                            edit.add_rectangle(active_points[0][0] // 2, active_points[0][1] // 2, active_points[1][0] // 2, active_points[1][1] // 2)
                            active_points = []
                    elif event.button == 3:
                        edit.remove_rectangle(event.pos[0] // 2, event.pos[1] // 2)
                        active_points = []
                elif event.pos[1] < 480 and edit.edit_mode == "enemies":
                    if event.button == 1: edit.add_enemy(event.pos[0] // 2, event.pos[1] // 2)
                    elif event.button == 3: edit.remove_enemy(event.pos[0] // 2, event.pos[1] // 2)
            elif event.type == pygame.KEYDOWN:
                if event.key == pygame.K_s:
                    edit.save_to_file()
                elif event.key == pygame.K_r:
                    edit.rectangles = []
                    edit.enemies = []
                elif event.key == pygame.K_LEFT and edit.edit_mode == "playfield":
                    edit.cur_color = (edit.cur_color - 1) % len(color_list)
                elif event.key == pygame.K_LEFT and edit.edit_mode == "enemies":
                    edit.cur_enemy = (edit.cur_enemy - 1) % len(entity_ref)
                elif event.key == pygame.K_RIGHT and edit.edit_mode == "playfield":
                    edit.cur_color = (edit.cur_color + 1) % len(color_list)
                elif event.key == pygame.K_RIGHT and edit.edit_mode == "enemies":
                    edit.cur_enemy = (edit.cur_enemy + 1) % len(entity_ref)
                elif event.key == pygame.K_UP and edit.cur_border < 256 and edit.edit_mode == "playfield":
                    edit.cur_border += 1
                elif event.key == pygame.K_DOWN and edit.cur_border > 0 and edit.edit_mode == "playfield":
                    edit.cur_border -= 1
                elif event.key == pygame.K_EQUALS and edit.snap_to < 16:
                    edit.snap_to *= 2
                elif event.key == pygame.K_MINUS and edit.snap_to > 1:
                    edit.snap_to //= 2
                elif event.key == pygame.K_SPACE:
                    if edit.edit_mode == "playfield": edit.edit_mode = "enemies"
                    else: edit.edit_mode = "playfield"
                elif pygame.K_0 <= event.key <= pygame.K_9:
                    if not appending_to_level:
                        edit.file_id = event.key - pygame.K_0
                        appending_to_level = True
                    else:
                        new_file = edit.file_id * 10 + event.key - pygame.K_0
                        if new_file < 256:
                            edit.file_id = new_file
                            if new_file > 26: appending_to_level = False
                elif event.key == pygame.K_RETURN:
                    appending_to_level = False
        draw_from_editor(edit)
        pygame.display.update()
    pygame.quit()

main()