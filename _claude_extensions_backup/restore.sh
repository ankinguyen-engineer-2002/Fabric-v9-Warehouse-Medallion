#!/bin/bash
# Restore Claude Code skills + agents
# Run: bash restore.sh

echo "Restoring Claude Code extensions..."

mkdir -p ~/.claude/skills
mkdir -p ~/.claude/agents

cp -r ./skills/* ~/.claude/skills/
cp -r ./agents/* ~/.claude/agents/

echo "✅ Restored $(ls ~/.claude/skills/ | wc -l) skills"
echo "✅ Restored $(ls ~/.claude/agents/ | wc -l) agents"
echo ""
echo "Skills: $(ls ~/.claude/skills/)"
echo "Agents: $(ls ~/.claude/agents/)"
