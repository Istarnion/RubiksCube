
static this()
{
    immutable ubyte[string] CHARACTER_MAP = [
        " ": 0,
        "☺": 1,
        "☻": 2,
        "♥": 3,
        "♦": 4,
        "♣": 5,
        "♠": 6,
        "§": 21,
        "!": 33,
        "\"": 34,
        "#": 35,
        "$": 36,
        "%": 37,
        "&": 38,
        "'": 39,
        "(": 40,
        ")": 41,
        "*": 42,
        "+": 43,
        ",": 44,
        "-": 45,
        ".": 46,
        "/": 47,
        "0": 48,
        "1": 49,
        "2": 50,
        "3": 51,
        "4": 52,
        "5": 53,
        "6": 54,
        "7": 55,
        "8": 56,
        "9": 57,
        ":": 58,
        ";": 59,
        "<": 60,
        "=": 61,
        ">": 62,
        "?": 63,
        "@": 64,
        "A": 65,
        "B": 66,
        "C": 67,
        "D": 68,
        "E": 69,
        "F": 70,
        "G": 71,
        "H": 72,
        "I": 73,
        "J": 74,
        "K": 75,
        "L": 76,
        "M": 77,
        "N": 78,
        "O": 79,
        "P": 80,
        "Q": 81,
        "R": 82,
        "S": 83,
        "T": 84,
        "U": 85,
        "V": 86,
        "W": 87,
        "X": 88,
        "Y": 89,
        "Z": 90,
        "[": 91,
        "\\": 92,
        "]": 93,
        "^": 94,
        "_": 95,
        "`": 96,
        "a": 97,
        "b": 98,
        "c": 99,
        "d": 100,
        "e": 101,
        "f": 102,
        "g": 103,
        "h": 104,
        "i": 105,
        "j": 106,
        "k": 107,
        "l": 108,
        "m": 109,
        "n": 110,
        "o": 111,
        "p": 112,
        "q": 113,
        "r": 114,
        "s": 115,
        "t": 116,
        "u": 117,
        "v": 118,
        "w": 119,
        "x": 120,
        "y": 121,
        "z": 122,
        "{": 123,
        "¦": 124,
        "}": 125,
        "~": 126,

        "ü": 129,
        "é": 130,

        "ä": 132,
        "à": 133,
        "å": 134,


        "ë": 137,
        "è": 138,
        "ï": 139,

        "ì": 141,
        "Ä": 142,
        "Å": 143,
        "É": 144,
        "æ": 145,
        "Æ": 146,

        "ö": 148,
        "ò": 149,

        "ù": 151,
        "ÿ": 152,
        "Ö": 153,
        "Ü": 154,
        "ø": 155,
        "£": 156,
        "Ø": 157,


        "á": 160,
        "í": 161,
        "ó": 162,
        "ú": 163,
        "ñ": 164,
        "Ñ": 165,
        "ª": 166,
        "º": 167,
        "¿": 168,
        "®": 169,

        "½": 171,
        "¼": 172,
        "¡": 173,
        "«": 174,
        "»": 175,





        "Á": 181,

        "À": 183,
        "©": 184,





        "¥": 190,









        "Ã": 199,
        "ð": 208,
        "Ð": 209,

        "Ë": 211,
        "È": 212,
        "¹": 213,


        "Ï": 214,


        "\n": 217,

    ];
}
