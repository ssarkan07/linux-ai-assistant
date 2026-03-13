#!/bin/bash

API_KEY=$GEMINI_API_KEY
LOGFILE="ai-devops.log"

if [ -z "$API_KEY" ]; then
  echo "❌ GEMINI_API_KEY not set"
  exit 1
fi

echo "========================================"
echo "🤖 AI DevOps Assistant (Conversational)"
echo "Type 'exit' to quit"
echo "========================================"

while true
do
    echo ""
    echo "You:"
    read PROMPT

    if [[ "$PROMPT" == "exit" ]]; then
        echo "👋 Goodbye!"
        break
    fi

    RESPONSE=$(curl -s \
      -H "Content-Type: application/json" \
      -X POST \
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$API_KEY" \
      -d "{
        \"contents\": [{
          \"parts\": [{
            \"text\": \"User request: $PROMPT. 
If this requires a Linux command respond like:
COMMAND: <command>
Otherwise respond normally like a helpful assistant.\"
          }]
        }]
      }")

    RESULT=$(echo "$RESPONSE" | jq -r '.candidates[0].content.parts[0].text')

    echo ""
    echo "Assistant:"
    echo "$RESULT"

    # Detect command
    if [[ "$RESULT" == COMMAND:* ]]; then
        COMMAND=$(echo "$RESULT" | sed 's/COMMAND: //')

        echo ""
        echo "⚡ Running command: $COMMAND"

        OUTPUT=$(eval "$COMMAND" 2>&1)

        echo ""
        echo "📤 Output:"
        echo "$OUTPUT"

        echo "$(date) | PROMPT: $PROMPT | CMD: $COMMAND | OUTPUT: $OUTPUT" >> $LOGFILE
    fi

done
