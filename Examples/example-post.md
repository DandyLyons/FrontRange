---
title: Getting Started with FrontRange
date: 2025-12-17
draft: false
author: FrontRange Team
tags:
  - swift
  - cli
  - tutorial
summary: Learn how to use FrontRange for managing YAML front matter in your markdown files.
featured: true
categories:
  - tutorial
$schema: ./schemas/blog-post.json
---

# Getting Started with FrontRange

FrontRange is a powerful Swift package for managing YAML front matter in text files.

## Installation

```bash
swift package add-dependency https://github.com/YourOrg/FrontRange
```

## Basic Usage

### Validate front matter

```bash
# Validate a single file
fr validate post.md --schema schemas/blog-post.json

# Validate all posts recursively
fr validate content/posts/ --recursive --schema schemas/blog-post.json
```

### Set a value with validation

```bash
fr set --key draft --value false post.md --validate
```

This example demonstrates a valid blog post with all required fields.
