# -*- coding: utf-8 -*-
#
# Configuration file for the Sphinx documentation builder.
#
# This file does only contain a selection of the most common options. For a
# full list see the documentation:
# http://www.sphinx-doc.org/en/master/config

# -- Path setup --------------------------------------------------------------

# If extensions (or modules to document with autodoc) are in another directory,
# add these directories to sys.path here. If the directory is relative to the
# documentation root, use os.path.abspath to make it absolute, like shown here.

import os
import sys
from datetime import datetime
import recommonmark
from recommonmark.transform import AutoStructify
from recommonmark.parser import CommonMarkParser
# sys.path.insert(0, os.path.abspath('.'))
sys.path.insert(0, os.path.abspath('_ext'))
sys.path.insert(0, os.path.abspath('docs'))

# -- Project information -----------------------------------------------------

author    = 'Xilinx, Inc.'
project   = 'xbtest - User guide'
project_u = project.replace(' ', '_')
copyright = '2018-' + datetime.now().strftime("%Y") + ', ' + author

# The short X.Y version
version = '6.0'
# The full version, including alpha/beta/rc tags
release = '6.0'

html_last_updated_fmt = datetime.now().strftime("%B %d, %Y")

# The master toctree document.
master_doc = 'index'

# -- General configuration ---------------------------------------------------

# If your documentation needs a minimal Sphinx version, state it here.
# needs_sphinx = '1.0'

# Add any Sphinx extension module names here, as strings. They can be
# extensions coming with Sphinx (named 'sphinx.ext.*') or your custom ones.
extensions = [
    'sphinx.ext.autodoc',
    'sphinx.ext.doctest',
    'sphinx.ext.intersphinx',
    'sphinx.ext.todo',
    'sphinx.ext.coverage',
    'sphinx.ext.mathjax',
    'sphinx.ext.ifconfig',
    'sphinx.ext.viewcode',
    'sphinx.ext.githubpages',
	'recommonmark',
	'sphinx_markdown_tables',
	#'edit_on_github',
    # Auto-generate section labels.
    'sphinx.ext.autosectionlabel',
	'rst2pdf.pdfbuilder'
]

# Prefix document path to section labels, otherwise autogenerated labels would look like 'heading'
# rather than 'path/to/file:heading'
autosectionlabel_prefix_document = True

# Configuration for rst2pdf
#   index - master document
#   rst2pdf - name of the file that will be created
#   Sample rst2pdf doc - title of the pdf
#   Your Name - author name in the pdf
pdf_documents = [(master_doc, project_u, project, author)]

# Configure 'Edit on GitHub' extension
edit_on_github_project = 'Xilinx/xbtest'
edit_on_github_branch  = 'master'

# Add any paths that contain templates here, relative to this directory.
templates_path = ['_templates']

# Expand/Collapse functionality
def setup(app):
    app.add_css_file('custom.css')

# The suffix(es) of source filenames.
# You can specify multiple suffix as a list of string:
# source_suffix = ['.rst', '.md']
source_suffix = {
    '.rst': 'restructuredtext',
    '.md' : 'markdown',
    #'.txt': 'restructuredtext',
}

# For MD support
source_parsers = {
    '.md': CommonMarkParser,
	# myst_parser testing
	#'.md':
}

# The language for content autogenerated by Sphinx. Refer to documentation
# for a list of supported languages.

# This is also used if you do content translation via gettext catalogs.
# Usually you set "language" from the command line for these cases.
language = None

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
# This pattern also affects html_static_path and html_extra_path.
exclude_patterns = []

# The name of the Pygments (syntax highlighting) style to use.
pygments_style = None

# -- Options for HTML output -------------------------------------------------

# The theme to use for HTML and HTML Help pages.  See the documentation for
# a list of builtin themes.
html_theme      = 'xilinx'
html_theme_path = ["./_themes"]

# Theme options are theme-specific and customize the look and feel of a theme
# further.  For a list of options available for each theme, see the
# documentation.
html_theme_options = {
    'prev_next_buttons_location': 'bottom',
    'collapse_navigation': False,
}

# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
html_static_path = ['_static']

# Custom sidebar templates, must be a dictionary that maps document names
# to template names.

# The default sidebars (for documents that don't match any pattern) are
# defined by theme itself.  Builtin themes are using these templates by
# default: ``['localtoc.html', 'relations.html', 'sourcelink.html',
# 'searchbox.html']``.
# html_sidebars = {}

# -- Options for HTMLHelp output ---------------------------------------------

# Output file base name for HTML help builder.
htmlhelp_basename = 'xbtest'

# -- Options for LaTeX output ------------------------------------------------
latex_engine = 'pdflatex'
latex_elements = {
    # The paper size ('letterpaper' or 'a4paper').
    'papersize': 'letterpaper',

    # The font size ('10pt', '11pt' or '12pt').
    'pointsize': '12pt',

    # Additional stuff for the LaTeX preamble.
    # 'preamble': '',

    # Latex figure (float) alignment
    # 'figure_align': 'htbp',
}

# Grouping the document tree into LaTeX files. List of tuples
# (source start file, target name, title,
#  author, documentclass [howto, manual, or own class]).
latex_documents = [
    (master_doc, 'ENTER YOUR LIBRARY ID HERE. FOR EXAMPLE: xfopencv.tex', 'ENTER YOUR LIBRARY PROJECT NAME HERE', 'Xilinx', 'manual'),
]

# -- Options for manual page output ------------------------------------------

# One entry per manual page. List of tuples
# (source start file, name, description, authors, manual section).
man_pages = [
    (master_doc, 'ENTER YOUR LIBRARY ID HERE. FOR EXAMPLE: xfopencv', 'ENTER YOUR LIBRARY PROJECT NAME HERE',
     [author], 1)
]

# -- Options for Texinfo output ----------------------------------------------

# Grouping the document tree into Texinfo files. List of tuples
# (source start file, target name, title, author,
#  dir menu entry, description, category)
texinfo_documents = [
    (master_doc, 'ENTER YOUR LIBRARY ID HERE. FOR EXAMPLE: xfopencv', 'ENTER YOUR LIBRARY PROJECT NAME HERE',
     author, 'Xilinx', 'One line description of project.',
     'Miscellaneous'),
]

# -- Options for Epub output -------------------------------------------------

# Bibliographic Dublin Core info.
epub_title = project

# The unique identifier of the text. This can be a ISBN number
# or the project homepage.
# epub_identifier = ''

# A unique identification for the text.
# epub_uid = ''

# A list of files that should not be packed into the epub file.
epub_exclude_files = ['search.html']

# -- Options for rinoh ------------------------------------------

rinoh_documents = [dict(   doc=master_doc,   # top-level file (index.rst)
                        target=project_u)]   # output file (manual.pdf)

# -- Extension configuration -------------------------------------------------
# At the bottom of conf.py
def setup(app):
    app.add_config_value('recommonmark_config', {
            'url_resolver': lambda url: github_doc_root + url,
            'auto_toc_tree_section': 'Contents',
            }, True)
    app.add_transform(AutoStructify)