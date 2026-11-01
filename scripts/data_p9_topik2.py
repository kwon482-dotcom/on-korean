# -*- coding: utf-8 -*-
"""
Phase 9: TOPIK II 중급 핵심 어휘 (200 words)
"""
try:
    from scripts.data_p9_topik2_p1 import P9_TOPIK2_WORDS_P1
    from scripts.data_p9_topik2_p2 import P9_TOPIK2_WORDS_P2
    from scripts.data_p9_topik2_p3 import P9_TOPIK2_WORDS_P3
    from scripts.data_p9_topik2_p4 import P9_TOPIK2_WORDS_P4
except ImportError:
    from data_p9_topik2_p1 import P9_TOPIK2_WORDS_P1
    from data_p9_topik2_p2 import P9_TOPIK2_WORDS_P2
    from data_p9_topik2_p3 import P9_TOPIK2_WORDS_P3
    from data_p9_topik2_p4 import P9_TOPIK2_WORDS_P4

P9_TOPIK2_WORDS = P9_TOPIK2_WORDS_P1 + P9_TOPIK2_WORDS_P2 + P9_TOPIK2_WORDS_P3 + P9_TOPIK2_WORDS_P4
