 "use client";

import { useState } from "react";
import { analyzeTab } from "./lib/tabAnalyzer";

export default function Home() {
  const [tabInput, setTabInput] = useState("");
  const [analysis, setAnalysis] = useState<any>(null);

  const handleAnalyze = () => {
    if (tabInput.trim()) {
      const result = analyzeTab(tabInput);
      setAnalysis(result);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900 p-8">
      <div className="max-w-6xl mx-auto">
        <header className="text-center mb-12">
          <h1 className="text-5xl font-bold text-white mb-4">
            🎸 Guitar Tab Scale Analyzer
          </h1>
          <p className="text-purple-200 text-lg">
            Paste your guitar tab below and discover what scales are being used
          </p>
        </header>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          {/* Input Section */}
          <div className="bg-white/10 backdrop-blur-lg rounded-2xl p-6 shadow-2xl">
            <h2 className="text-2xl font-semibold text-white mb-4">
              Guitar Tab Input
            </h2>
            <textarea
              value={tabInput}
              onChange={(e) => setTabInput(e.target.value)}
              placeholder="Paste your guitar tab here...&#10;&#10;Example:&#10;E|--0--2--3--5--&#10;A|--0--2--4--5--&#10;D|--0--2--4--5--&#10;G|--0--2--4--5--&#10;B|--0--1--3--5--&#10;e|--0--2--3--5--"
              className="w-full h-96 bg-slate-800/50 text-white font-mono text-sm p-4 rounded-lg border border-purple-500/30 focus:border-purple-500 focus:outline-none resize-none"
            />
            <button
              onClick={handleAnalyze}
              className="mt-4 w-full bg-gradient-to-r from-purple-600 to-pink-600 hover:from-purple-700 hover:to-pink-700 text-white font-semibold py-3 px-6 rounded-lg transition-all transform hover:scale-105 shadow-lg"
            >
              Analyze Scales
            </button>
          </div>

          {/* Results Section */}
          <div className="bg-white/10 backdrop-blur-lg rounded-2xl p-6 shadow-2xl">
            <h2 className="text-2xl font-semibold text-white mb-4">
              Scale Analysis
            </h2>
            {!analysis ? (
              <div className="flex items-center justify-center h-96 text-purple-300">
                <div className="text-center">
                  <div className="text-6xl mb-4">🎵</div>
                  <p>Paste a tab and click &quot;Analyze Scales&quot; to get started</p>
                </div>
              </div>
            ) : (
              <div className="space-y-6 h-96 overflow-y-auto pr-2">
                {/* Notes Found */}
                <div className="bg-slate-800/50 rounded-lg p-4">
                  <h3 className="text-lg font-semibold text-purple-300 mb-2">
                    Notes Detected
                  </h3>
                  <div className="flex flex-wrap gap-2">
                    {analysis.uniqueNotes.map((note: string) => (
                      <span
                        key={note}
                        className="bg-purple-600/30 text-purple-200 px-3 py-1 rounded-full text-sm"
                      >
                        {note}
                      </span>
                    ))}
                  </div>
                </div>

                {/* Possible Scales */}
                <div className="bg-slate-800/50 rounded-lg p-4">
                  <h3 className="text-lg font-semibold text-green-300 mb-3">
                    Possible Scales
                  </h3>
                  {analysis.possibleScales.length === 0 ? (
                    <p className="text-gray-400">No matching scales found</p>
                  ) : (
                    <div className="space-y-3">
                      {analysis.possibleScales.map((scale: any, idx: number) => (
                        <div
                          key={idx}
                          className="bg-green-900/20 border border-green-500/30 rounded-lg p-3"
                        >
                          <div className="flex items-center justify-between mb-2">
                            <span className="text-white font-semibold">
                              {scale.name}
                            </span>
                            <span className="text-green-400 text-sm">
                              {scale.matchPercentage}% match
                            </span>
                          </div>
                          <div className="text-sm text-gray-300">
                            Scale notes: {scale.notes.join(", ")}
                          </div>
                        </div>
                      ))}
                    </div>
                  )}
                </div>

                {/* Statistics */}
                <div className="bg-slate-800/50 rounded-lg p-4">
                  <h3 className="text-lg font-semibold text-blue-300 mb-2">
                    Statistics
                  </h3>
                  <div className="space-y-1 text-sm text-gray-300">
                    <p>Total notes found: {analysis.totalNotes}</p>
                    <p>Unique notes: {analysis.uniqueNotes.length}</p>
                    <p>Strings analyzed: {analysis.stringsAnalyzed}</p>
                  </div>
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Instructions */}
        <div className="mt-8 bg-white/5 backdrop-blur-lg rounded-2xl p-6">
          <h3 className="text-xl font-semibold text-white mb-3">
            How to use:
          </h3>
          <ol className="list-decimal list-inside space-y-2 text-purple-200">
            <li>Paste your guitar tab in standard notation (E, A, D, G, B, e strings)</li>
            <li>The analyzer will extract all notes from the fret numbers</li>
            <li>It will identify which scales match the notes you&apos;re playing</li>
            <li>Higher match percentages mean better scale fits</li>
          </ol>
        </div>
      </div>
    </div>
  );
}
