# -*- coding: utf-8 -*-
import re

with open('lib/screens/dashboard_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

old_insight = '''        if (tempAlert != null) {
          alertText = "Temperature asymmetry detected in \. "
              "Max difference: \Â°C";
          alertColor = Colors.orange;'''

new_insight = '''        if (tempAlert != null) {
          alertText = "Inflammation risk in \ feet (\). "
              "Difference: \°C";
          alertColor = Colors.redAccent;'''
          
text = text.replace(old_insight, new_insight)

old_live = '''                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.circle, color: Colors.green, size: 8),
                        SizedBox(width: 6),
                        Text(
                          "LIVE",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),'''

new_live = '''                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.circle, color: Colors.green, size: 8),
                        const SizedBox(width: 6),
                        Text(
                          provider.lastSyncTime != null 
                             ? "LIVE (Sync: \:\)"
                             : "LIVE",
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),'''

text = text.replace(old_live, new_live)

with open('lib/screens/dashboard_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)

print("done")
