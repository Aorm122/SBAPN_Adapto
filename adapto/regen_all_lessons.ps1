# regen_all_lessons.ps1
# Run this from C:\SBAPN_Adapto\adapto\ after creating your .env file.
# Re-generates all existing lesson .tres files with the new schema
# (clues[], distractors[], Bloom's Taxonomy definitions).
#
# Usage:
#   cd adapto
#   .\regen_all_lessons.ps1             # re-generate everything
#   .\regen_all_lessons.ps1 -FailedOnly # re-run only previously failed topics

param(
    [switch]$FailedOnly
)

$ErrorActionPreference = "Continue"

Write-Host "`n=== AdapTo Lesson Regenerator ===" -ForegroundColor Cyan
Write-Host "Regenerating all lessons with new schema (clues, distractors, Bloom's Taxonomy)`n"

# Tracks which lessons failed
$failed = [System.Collections.Generic.List[string]]::new()
$succeeded = [System.Collections.Generic.List[string]]::new()

# ─── Helper: run one lesson, retry up to $MaxRetries times on failure ─────────
function Invoke-Lesson {
    param(
        [string]$Label,
        [string[]]$PythonArgs,
        [int]$MaxRetries = 3,
        [int]$RetryDelaySec = 15
    )
    $attempt = 0
    $ok = $false
    while ($attempt -lt $MaxRetries -and -not $ok) {
        $attempt++
        if ($attempt -gt 1) {
            Write-Host "  Retry $attempt/$MaxRetries in $($RetryDelaySec)s..." -ForegroundColor DarkYellow
            Start-Sleep -Seconds $RetryDelaySec
            $RetryDelaySec = [Math]::Min($RetryDelaySec * 2, 120)
        }
        $output = python Lessons/generate_lesson.py @PythonArgs 2>&1
        $exitCode = $LASTEXITCODE
        Write-Host $output
        if ($exitCode -eq 0) {
            $ok = $true
        }
    }
    return $ok
}

# ─── PDF-sourced lessons ──────────────────────────────────────────────────────
$pdfLessons = @(
    [pscustomobject]@{ Label="Distributed Systems (Architecture)"; Pdf="1-Distriduted System (Architecture Style)_8743c5a9780a0933368989c90d23dcd7-merged.pdf"; Folder="1-Distriduted System (Architecture Style)_8743c5a9780a0933368989c90d23dcd7-merged" },
    [pscustomobject]@{ Label="Introduction to Algorithms";         Pdf="1.1. Introduction to Algorithms.pdf";                                                    Folder="1.1. Introduction to Algorithms" },
    [pscustomobject]@{ Label="1st Grade Workbook";                 Pdf="1stGrade-Workbook.pdf";                                                                  Folder="1stGrade-Workbook" },
    [pscustomobject]@{ Label="Naming in Distributed Systems";      Pdf="5-Naming-in-Distributed-Systems-merged.pdf";                                            Folder="5-Naming-in-Distributed-Systems-merged" },
    [pscustomobject]@{ Label="Central Limit Theorem";              Pdf="8. Central Limit Theorem.pdf";                                                           Folder="8. Central Limit Theorem" }
)

if (-not $FailedOnly) {
    foreach ($lesson in $pdfLessons) {
        Write-Host "[PDF] $($lesson.Label)" -ForegroundColor Yellow
        $ok = Invoke-Lesson -Label $lesson.Label -PythonArgs @("--pdf", $lesson.Pdf, "60", $lesson.Folder)
        if ($ok) { $succeeded.Add($lesson.Label) } else { $failed.Add($lesson.Label) }
        Write-Host ""
    }
}

# ─── Topic-based lessons ──────────────────────────────────────────────────────
$topicLessons = @(
    [pscustomobject]@{ Label="Automata Theory CFG (at)";                 Topic="Automata Theory CFG";                                    Count=16; Folder="at" },
    [pscustomobject]@{ Label="Automata Theory - CFG";                    Topic="Automata Theory - CFG";                                  Count=16; Folder="Automata Theory - CFG" },
    [pscustomobject]@{ Label="Distributed Systems Communication";        Topic="Distributed Systems communication naming synchronization"; Count=20; Folder="Distributed Systems - communication, naming and syncronization" },
    [pscustomobject]@{ Label="Distributed Systems (DS)";                 Topic="Distributed Systems";                                    Count=16; Folder="DS" },
    [pscustomobject]@{ Label="English Literature";                       Topic="English Literature";                                     Count=16; Folder="English literature" },
    [pscustomobject]@{ Label="Linear Algebra Matrices";                  Topic="Linear Algebra Matrices";                                Count=16; Folder="la" },
    [pscustomobject]@{ Label="Linear Programming";                       Topic="Linear Programming";                                     Count=16; Folder="Linear Programming" },
    [pscustomobject]@{ Label="Software Modelling UML";                   Topic="Software Modelling UML";                                 Count=16; Folder="Modelling" },
    [pscustomobject]@{ Label="Object Oriented Programming";              Topic="Object Oriented Programming";                            Count=16; Folder="Object Oriented" },
    [pscustomobject]@{ Label="Pokemon";                                  Topic="Pokemon";                                                Count=16; Folder="pkmn" },
    [pscustomobject]@{ Label="Systems Analysis and Design";              Topic="Systems Analysis and Design";                            Count=16; Folder="SAD" },
    [pscustomobject]@{ Label="Sigmund Freud Theories";                   Topic="Sigmund Freud Theories";                                 Count=16; Folder="Sigmund Freud Theories" },
    [pscustomobject]@{ Label="Software Engineering";                     Topic="Software Engineering";                                   Count=16; Folder="Software Engineering" },
    [pscustomobject]@{ Label="Web Design";                               Topic="Web Design";                                             Count=16; Folder="Web Design" },
    [pscustomobject]@{ Label="Web Development";                          Topic="Web Development";                                        Count=16; Folder="Web Dev" },
    [pscustomobject]@{ Label="Data Structures";                          Topic="Data Structures";                                        Count=16; Folder="Wimby" }
)

foreach ($lesson in $topicLessons) {
    Write-Host "[TOPIC] $($lesson.Label)" -ForegroundColor Green
    $ok = Invoke-Lesson -Label $lesson.Label -PythonArgs @($lesson.Topic, $lesson.Count, $lesson.Folder)
    if ($ok) { $succeeded.Add($lesson.Label) } else { $failed.Add($lesson.Label) }
    Write-Host ""
}

# ─── Final summary ────────────────────────────────────────────────────────────
Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  REGENERATION COMPLETE" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Succeeded: $($succeeded.Count)" -ForegroundColor Green
Write-Host "  Failed:    $($failed.Count)" -ForegroundColor $(if ($failed.Count -gt 0) { "Red" } else { "Green" })

if ($failed.Count -gt 0) {
    Write-Host "`nFailed lessons:" -ForegroundColor Red
    foreach ($f in $failed) { Write-Host "  - $f" -ForegroundColor Red }
    Write-Host "`nTo retry failed lessons only, run:" -ForegroundColor Yellow
    Write-Host "  .\regen_all_lessons.ps1 -FailedOnly" -ForegroundColor Yellow
} else {
    Write-Host "`nAll lessons regenerated successfully!" -ForegroundColor Green
    Write-Host "Reload the Godot project to pick up the updated .tres files." -ForegroundColor Cyan
}
