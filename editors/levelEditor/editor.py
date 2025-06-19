import pygame
from sprite import Text

color_list = [((0, 0, 0), 0), ((255, 255, 255), 1)]

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

    def __init__(self, num):
        self.rectangles = []
        self.cur_color = 0
        self.cur_border = 0
        self.snap_to = 1
        self.file_id = num
    
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

    def save_to_file(self):
        if self.file_id == -1:
            return -1
        int_16 = lambda x : [(x % 65536) % 256, (x % 65536) // 256]
        int_to_fixed = lambda x : [((x * 4) % 65536) % 256, ((x * 4) % 65536) // 256]
        header = [0] * 6
        playfield = []
        solid_colliders = []
        enemies = []
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
        if playfield == []: playfield = [0]
        if solid_colliders == []: solid_colliders = [0]
        if enemies == []: enemies = [0] 
        header[0] = 6
        header[2] = (len(playfield) + 6) % 256
        header[3] = (len(playfield) + 6) // 256
        header[4] = (len(solid_colliders) + len(playfield) + 6) % 256
        header[5] = (len(solid_colliders) + len(playfield) + 6) // 256
        full_file = bytes(header + playfield + solid_colliders + enemies)
        if len(full_file) > 2048: return -1
        with open("LVL{}.BIN".format(hex(self.file_id)[2:].zfill(2)).upper(), "wb") as file:
            file.write(full_file)
            file.close()
        return 0

                      
            
    
def draw_from_editor(edit, screen):
    colors = [(100, 100, 100), (125, 125, 125)]
    col_index = 0
    screen.fill((0, 0, 0))
    for i in range(240 // edit.snap_to):
        for j in range(320 // edit.snap_to):
            pygame.draw.rect(screen, colors[col_index], [2 * j * edit.snap_to, 2 * i * edit.snap_to, 2 * edit.snap_to, 2 * edit.snap_to])
            col_index = (col_index + 1) % 2
        col_index = (col_index + 1) % 2
    for r in edit.rectangles:
        pygame.draw.rect(screen, color_list[r[0]][0], [2 * r[2][0], 2 * r[2][1], 2 * r[2][2], 2 * r[2][3]])
        if (r[1] > 0 and r[2][2] - 2 * r[1] > 0 and r[2][3] - 2 * r[1] > 0):
            pygame.draw.rect(screen, (0, 0, 0), [2 * (r[2][0] + r[1]), 2 * (r[2][1] + r[1]), 2 * (r[2][2] - 2 * r[1]), 2 * (r[2][3] - 2 * r[1])])
    


def main():
    pygame.init()
    screen = pygame.display.set_mode((640, 640))
    edit = Editor(0)
    edit.cur_color = 1
    running = True
    active_points = []
    edit_mode = "playfield"
    while running:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
            elif event.type == pygame.MOUSEBUTTONDOWN:
                if event.pos[1] < 480 and edit_mode == "playfield":
                    if event.button == 1:
                        active_points.append(event.pos)
                        if len(active_points) == 2:
                            edit.add_rectangle(active_points[0][0] // 2, active_points[0][1] // 2, active_points[1][0] // 2, active_points[1][1] // 2)
                            active_points = []
                    elif event.button == 3:
                        edit.remove_rectangle(event.pos[0] // 2, event.pos[1] // 2)
                        active_points = []
            elif event.type == pygame.KEYDOWN:
                if event.key == pygame.K_s:
                    edit.save_to_file()
                elif event.key == pygame.K_LEFT:
                    edit.cur_color = (edit.cur_color + 1) % len(color_list)
                elif event.key == pygame.K_RIGHT:
                    edit.cur_color = (edit.cur_color - 1) % len(color_list)
                elif event.key == pygame.K_UP and edit.cur_border < 256:
                    edit.cur_border += 1
                elif event.key == pygame.K_DOWN and edit.cur_border > 0:
                    edit.cur_border -= 1
                elif event.key == pygame.K_EQUALS and edit.snap_to < 16:
                    edit.snap_to *= 2
                elif event.key == pygame.K_MINUS and edit.snap_to > 1:
                    edit.snap_to //= 2
        draw_from_editor(edit, screen)
        if edit_mode == "playfield":
            t = Text("Color-", 20, 500, (255, 255, 255), 2, screen)
            t.update()
            t = Text("Level-", 20, 540, (255, 255, 255), 2, screen)
            t.update()
        pygame.display.update()
    pygame.quit()

main()