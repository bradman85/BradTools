 // Guitar string tuning (standard tuning)
const STANDARD_TUNING = {
  e: ["E", "F", "F#", "G", "G#", "A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B", "C", "C#", "D", "D#"],
  B: ["B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#"],
  G: ["G", "G#", "A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#"],
  D: ["D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B", "C", "C#"],
  A: ["A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#"],
  E: ["E", "F", "F#", "G", "G#", "A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B", "C", "C#", "D", "D#"],
};

// Common scales and their intervals
const SCALES = {
  "Major (Ionian)": [0, 2, 4, 5, 7, 9, 11],
  "Natural Minor (Aeolian)": [0, 2, 3, 5, 7, 8, 10],
  "Harmonic Minor": [0, 2, 3, 5, 7, 8, 11],
  "Melodic Minor": [0, 2, 3, 5, 7, 9, 11],
  "Dorian": [0, 2, 3, 5, 7, 9, 10],
  "Phrygian": [0, 1, 3, 5, 7, 8, 10],
  "Lydian": [0, 2, 4, 6, 7, 9, 11],
  "Mixolydian": [0, 2, 4, 5, 7, 9, 10],
  "Locrian": [0, 1, 3, 5, 6, 8, 10],
  "Minor Pentatonic": [0, 3, 5, 7, 10],
  "Major Pentatonic": [0, 2, 4, 7, 9],
  "Blues Scale": [0, 3, 5, 6, 7, 10],
  "Chromatic": [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
};

const NOTES = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"];

// Generate scale notes from root note and intervals
function generateScale(rootNote: string, intervals: number[]): string[] {
  const rootIndex = NOTES.indexOf(rootNote);
  if (rootIndex === -1) return [];
  
  return intervals.map(interval => {
    const noteIndex = (rootIndex + interval) % 12;
    return NOTES[noteIndex];
  });
}

// Parse guitar tab and extract notes
export function parseTab(tabText: string): string[] {
  const notes: string[] = [];
  const lines = tabText.split("\n");
  
  for (const line of lines) {
    // Identify which string this line represents
    let stringName = "";
    if (line.trim().startsWith("e|") || line.trim().startsWith("E|")) {
      stringName = line.trim().toLowerCase().startsWith("e|") && 
                   lines.some(l => l.trim().startsWith("E|")) ? "e" : "E";
    } else if (line.trim().startsWith("B|")) {
      stringName = "B";
    } else if (line.trim().startsWith("G|")) {
      stringName = "G";
    } else if (line.trim().startsWith("D|")) {
      stringName = "D";
    } else if (line.trim().startsWith("A|")) {
      stringName = "A";
    }
    
    if (!stringName) continue;
    
    // Extract fret numbers from the line
    const fretMatches = line.match(/\d+/g);
    if (fretMatches) {
      for (const fretStr of fretMatches) {
        const fret = parseInt(fretStr, 10);
        if (fret >= 0 && fret < 24) {
          const tuning = STANDARD_TUNING[stringName as keyof typeof STANDARD_TUNING];
          if (tuning && tuning[fret]) {
            notes.push(tuning[fret]);
          }
        }
      }
    }
  }
  
  return notes;
}

// Analyze which scales match the given notes
export function analyzeTab(tabText: string) {
  const notes = parseTab(tabText);
  const uniqueNotes = Array.from(new Set(notes));
  
  // Find all possible scales
  const possibleScales: Array<{
    name: string;
    notes: string[];
    matchPercentage: number;
  }> = [];
  
  // Try each scale type with each root note
  for (const [scaleName, intervals] of Object.entries(SCALES)) {
    for (const rootNote of NOTES) {
      const scaleNotes = generateScale(rootNote, intervals);
      
      // Check how many of the played notes are in this scale
      const matchingNotes = uniqueNotes.filter(note => scaleNotes.includes(note));
      const matchPercentage = Math.round((matchingNotes.length / uniqueNotes.length) * 100);
      
      // Only include scales with high match percentage
      if (matchPercentage >= 70) {
        possibleScales.push({
          name: `${rootNote} ${scaleName}`,
          notes: scaleNotes,
          matchPercentage,
        });
      }
    }
  }
  
  // Sort by match percentage (highest first)
  possibleScales.sort((a, b) => b.matchPercentage - a.matchPercentage);
  
  // Count strings analyzed
  const stringsAnalyzed = new Set(
    tabText.split("\n")
      .filter(line => /^[eEBGDA]\|/.test(line.trim()))
      .map(line => line.trim()[0])
  ).size;
  
  return {
    totalNotes: notes.length,
    uniqueNotes,
    possibleScales: possibleScales.slice(0, 10), // Top 10 matches
    stringsAnalyzed,
  };
}
