# | 🙑  dismint
# | YW5uaWUgPDM=

#### COLORS ####

old_colors = {
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
    "dragon_white": [
        "#",
        "#F8F8F8",
    ],
}

colors = {
    "dragonBlack0": "#0D0C0C",
    "dragonBlack1": "#12120F",
    "dragonBlack2": "#1D1C19",
    "dragonBlack3": "#181616",
    "dragonBlack4": "#282727",
    "dragonBlack5": "#393836",
    "dragonBlack6": "#625E5A",
    "dragonGray": "#A6A69C",
    "dragonGray2": "#9E9B93",
    "dragonGray3": "#7A8382",
    "dragonWhite": "#C5C9C5",
    "dragonGreen": "#87A987",
    "dragonGreen2": "#8A9A7B",
    "dragonBlue": "#658594",
    "dragonBlue2": "#8BA4B0",
    "dragonViolet": "#8992A7",
    "dragonAqua": "#8EA4A2",
    "dragonTeal": "#949FB5",
    "dragonPink": "#A292A3",
    "dragonYellow": "#C4B28A",
    "dragonOrange": "#B6927B",
    "dragonOrange2": "#B98D7B",
    "dragonRed": "#C4746E",
    "dragonAsh": "#737C73",
    "lotusInk1": "#545464",
    "lotusInk2": "#43436c",
    "lotusGray": "#dcd7ba",
    "lotusGray2": "#716e61",
    "lotusGray3": "#8a8980",
    "lotusWhite0": "#d5cea3",
    "lotusWhite1": "#dcd5ac",
    "lotusWhite2": "#e5ddb0",
    "lotusWhite3": "#f2ecbc",
    "lotusWhite4": "#e7dba0",
    "lotusWhite5": "#e4d794",
    "lotusViolet1": "#a09cac",
    "lotusViolet2": "#766b90",
    "lotusViolet3": "#c9cbd1",
    "lotusViolet4": "#624c83",
    "lotusBlue1": "#c7d7e0",
    "lotusBlue2": "#b5cbd2",
    "lotusBlue3": "#9fb5c9",
    "lotusBlue4": "#4d699b",
    "lotusBlue5": "#5d57a3",
    "lotusGreen": "#6f894e",
    "lotusGreen2": "#6e915f",
    "lotusGreen3": "#b7d0ae",
    "lotusPink": "#b35b79",
    "lotusOrange": "#cc6d00",
    "lotusOrange2": "#e98a00",
    "lotusYellow": "#77713f",
    "lotusYellow2": "#836f4a",
    "lotusYellow3": "#de9800",
    "lotusYellow4": "#f9d791",
    "lotusRed": "#c84053",
    "lotusRed2": "#d7474b",
    "lotusRed3": "#e82424",
    "lotusRed4": "#d9a594",
    "lotusAqua": "#597b75",
    "lotusAqua2": "#5e857a",
    "lotusTeal1": "#4e8ca2",
    "lotusTeal2": "#6693bf",
    "lotusTeal3": "#5a7785",
    "lotusCyan": "#d7e3d8",
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
        print(f"\n{color}: ", end="")
        hex_color = colors[color]
        r, g, b = tuple(int(hex_color[i : i + 2], 16) for i in (1, 3, 5))
        color_256 = rgb_to_256(r, g, b)
        print_colored_hex(hex_color, color_256)


def main():
    print_color_list()


if __name__ == "__main__":
    main()
