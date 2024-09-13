# | 🙑  dismint
# | YW5uaWUgPDM=

#### COLORS ####

colors = {
    "green": [
        "#287E6B",
        "#308673",
        "#519F8A",
        "#87C3AA",
        "#A4D3BA",
        "#C7E8D3",
        "#EEFAEB",
    ],
    "blue": [
        "#315288",
        "#7B9EC4",
        "#D8F2F3",
    ],
    "purple": [
        "#6A4089",
        "#A98FCB",
        "#E5EDFF",
    ],
}

#### IMPL ####

cube_levels = [0x00, 0x5F, 0x87, 0xAF, 0xD7, 0xFF]
snaps = [(x + y) / 2 for x, y in zip(cube_levels, [0] + cube_levels)][1:]

def rgb_to_256(r, g, b):
    def transform(x):
        return len(tuple(s for s in snaps if s < x))

    r, g, b = map(transform, (r, g, b))
    return r * 36 + g * 6 + b + 16

def print_colored_hex(color_hex, color_256):
    print(f"\033[38;5;{color_256}m{color_hex} [{color_256}]\033[0m")
    # ]] <- this fixes weird indentation bug

def print_color_list():
    for color in colors:
        print(f"\n{color}:")
        for hex_color in colors[color]:
            r, g, b = tuple(int(hex_color[i:i+2], 16) for i in (1, 3, 5))
            color_256 = rgb_to_256(r, g, b)
            print_colored_hex(hex_color, color_256)

def main():
    print_color_list()

if __name__ == "__main__":
    main()

