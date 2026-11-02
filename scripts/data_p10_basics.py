# -*- coding: utf-8 -*-
"""
Phase 10: Basics (200 words)
"""
try:
    from scripts.data_p10_basics_p1 import P10_BASICS_WORDS_P1
    from scripts.data_p10_basics_p2 import P10_BASICS_WORDS_P2
    from scripts.data_p10_basics_p3 import P10_BASICS_WORDS_P3
    from scripts.data_p10_basics_p4 import P10_BASICS_WORDS_P4
except ImportError:
    from data_p10_basics_p1 import P10_BASICS_WORDS_P1
    from data_p10_basics_p2 import P10_BASICS_WORDS_P2
    from data_p10_basics_p3 import P10_BASICS_WORDS_P3
    from data_p10_basics_p4 import P10_BASICS_WORDS_P4

P10_BASICS_WORDS = P10_BASICS_WORDS_P1 + P10_BASICS_WORDS_P2 + P10_BASICS_WORDS_P3 + P10_BASICS_WORDS_P4
