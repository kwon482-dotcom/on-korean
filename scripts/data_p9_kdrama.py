# -*- coding: utf-8 -*-
"""
Phase 9: K-드라마 & 실전 리얼 회화 (200 words)
"""
try:
    from scripts.data_p9_kdrama_p1 import P9_KDRAMA_WORDS_P1
    from scripts.data_p9_kdrama_p2 import P9_KDRAMA_WORDS_P2
    from scripts.data_p9_kdrama_p3 import P9_KDRAMA_WORDS_P3
    from scripts.data_p9_kdrama_p4 import P9_KDRAMA_WORDS_P4
except ImportError:
    from data_p9_kdrama_p1 import P9_KDRAMA_WORDS_P1
    from data_p9_kdrama_p2 import P9_KDRAMA_WORDS_P2
    from data_p9_kdrama_p3 import P9_KDRAMA_WORDS_P3
    from data_p9_kdrama_p4 import P9_KDRAMA_WORDS_P4

P9_KDRAMA_WORDS = P9_KDRAMA_WORDS_P1 + P9_KDRAMA_WORDS_P2 + P9_KDRAMA_WORDS_P3 + P9_KDRAMA_WORDS_P4
