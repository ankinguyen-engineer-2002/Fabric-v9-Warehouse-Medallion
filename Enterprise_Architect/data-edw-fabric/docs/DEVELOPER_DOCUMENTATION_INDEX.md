# Developer Documentation Index

## 📚 Complete Guide for Fabric SQL Warehouse Development

Welcome to the EDW-Fabric developer documentation. This index helps you find the right guide for your needs.

---

## 🎯 Quick Navigation

### I'm New to This Project
1. Start with: **DEVELOPER_BEST_PRACTICES_GUIDE.md**
2. Then read: **QUICK_REFERENCE_CARD.md**
3. Keep handy: **TROUBLESHOOTING_GUIDE.md**

### I Need to Configure a Project
1. Read: **SQLPROJ_BEST_PRACTICES.md**
2. Reference: **QUICK_REFERENCE_CARD.md** - .sqlproj Template

### I'm Debugging an Issue
1. Check: **TROUBLESHOOTING_GUIDE.md**
2. Reference: **QUICK_REFERENCE_CARD.md** - Common Errors

### I Need to Write SQL Code
1. Read: **DEVELOPER_BEST_PRACTICES_GUIDE.md** - SQL Development section
2. Reference: **QUICK_REFERENCE_CARD.md** - Cross-Database References

---

## 📖 Documentation Files

### DEVELOPER_BEST_PRACTICES_GUIDE.md
**Purpose**: Comprehensive guide for all developers  
**Best For**: New developers, comprehensive reference  
**Topics**: Project structure, configuration, naming, SQL development, build & deployment

### QUICK_REFERENCE_CARD.md
**Purpose**: Quick lookup reference for common tasks  
**Best For**: Quick answers, templates, commands  
**Topics**: Commands, templates, naming table, error fixes, architecture

### SQLPROJ_BEST_PRACTICES.md
**Purpose**: Detailed guide for .sqlproj configuration  
**Best For**: Configuration issues, new projects  
**Topics**: SDK, PropertyGroup, SqlCmdVariable, ProjectReference, templates

### TROUBLESHOOTING_GUIDE.md
**Purpose**: Solutions for common problems  
**Best For**: Debugging, error resolution  
**Topics**: Build issues, deployment issues, SQL issues, performance issues

---

## 🔄 Data Architecture

### Three-Layer Architecture

```
Gold Layer (Business-Ready)
├── Retail_Warehouse_Gold
└── Optimized for reporting

Silver Layer (Cleaned & Standardized)
├── Retail_Warehouse
├── Finance_Warehouse
└── Business logic applied

Bronze Layer (Raw Data)
├── Source_Data
└── Minimal transformation
```

---

## 📋 Common Tasks

### Task: Create a New Project
1. Read: SQLPROJ_BEST_PRACTICES.md → Template section
2. Use: QUICK_REFERENCE_CARD.md → .sqlproj Template
3. Reference: DEVELOPER_BEST_PRACTICES_GUIDE.md → Project Structure

### Task: Add Cross-Database Reference
1. Check: DEVELOPER_BEST_PRACTICES_GUIDE.md → Cross-Database References
2. Reference: QUICK_REFERENCE_CARD.md → Cross-Database Reference Pattern
3. Verify: TROUBLESHOOTING_GUIDE.md → SQL Development Issues

### Task: Fix Build Error
1. Check: TROUBLESHOOTING_GUIDE.md → Build Issues
2. Reference: QUICK_REFERENCE_CARD.md → Common Errors & Fixes
3. Validate: QUICK_REFERENCE_CARD.md → Pre-Commit Checklist

### Task: Deploy to Production
1. Read: DEVELOPER_BEST_PRACTICES_GUIDE.md → Build & Deployment
2. Reference: QUICK_REFERENCE_CARD.md → Quick Start Commands
3. Verify: QUICK_REFERENCE_CARD.md → Pre-Commit Checklist

---

## 🎓 Learning Path

### Beginner (Week 1)
- [ ] Read DEVELOPER_BEST_PRACTICES_GUIDE.md
- [ ] Review QUICK_REFERENCE_CARD.md
- [ ] Study example projects in repository
- [ ] Build a simple project locally

### Intermediate (Week 2-3)
- [ ] Read SQLPROJ_BEST_PRACTICES.md
- [ ] Create a new project from template
- [ ] Add cross-database references
- [ ] Deploy to development environment

### Advanced (Week 4+)
- [ ] Optimize SQL queries
- [ ] Troubleshoot complex issues
- [ ] Review and improve existing projects
- [ ] Mentor new developers

---

## 🔍 Search Guide

| I need to find... | Check this file |
|------------------|-----------------|
| How to name objects | QUICK_REFERENCE_CARD.md |
| .sqlproj template | QUICK_REFERENCE_CARD.md or SQLPROJ_BEST_PRACTICES.md |
| Build commands | QUICK_REFERENCE_CARD.md |
| Cross-database reference syntax | QUICK_REFERENCE_CARD.md or DEVELOPER_BEST_PRACTICES_GUIDE.md |
| Troubleshoot build error | TROUBLESHOOTING_GUIDE.md |
| Troubleshoot deployment error | TROUBLESHOOTING_GUIDE.md |
| Fabric unsupported features | QUICK_REFERENCE_CARD.md or DEVELOPER_BEST_PRACTICES_GUIDE.md |
| Pre-commit checklist | QUICK_REFERENCE_CARD.md or DEVELOPER_BEST_PRACTICES_GUIDE.md |
| Project structure | DEVELOPER_BEST_PRACTICES_GUIDE.md |
| Configuration standards | SQLPROJ_BEST_PRACTICES.md or DEVELOPER_BEST_PRACTICES_GUIDE.md |

---

## 📞 Support

### Questions About Guides?
- Check this index for navigation
- Review specific guide for detailed information
- Contact data engineering team

### Need to Update Guides?
- Guides are in `docs/` folder
- Use Markdown format
- Keep consistent with existing style

---

## ✅ Validation

Before starting development:

- [ ] Read DEVELOPER_BEST_PRACTICES_GUIDE.md
- [ ] Bookmark QUICK_REFERENCE_CARD.md
- [ ] Understand data architecture layers
- [ ] Know naming conventions
- [ ] Understand cross-database references
- [ ] Know how to build locally
- [ ] Know where to find help

---

## 🚀 Getting Started

1. **Read**: DEVELOPER_BEST_PRACTICES_GUIDE.md (30 minutes)
2. **Review**: QUICK_REFERENCE_CARD.md (10 minutes)
3. **Practice**: Build an existing project locally (15 minutes)
4. **Explore**: Review similar projects (20 minutes)
5. **Ready**: Start development!

---

**Last Updated**: October 21, 2025  
**Version**: 1.0  
**Status**: Active

