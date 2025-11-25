// script.js

// Function to trigger hidden file input for Excel/CSV import
function triggerImport() {
  const input = document.getElementById("excelFileInput");
  if (input) {
    input.click();
  }
}

// Listen for file selection and handle the selected file
document.addEventListener("DOMContentLoaded", () => {
  const excelInput = document.getElementById("excelFileInput");
  if (excelInput) {
    excelInput.addEventListener("change", (event) => {
      const file = event.target.files[0];
      if (file) {
        console.log("Selected file:", file.name);
        const allowed = ["csv", "xlsx", "xls"];
        const ext = file.name.split(".").pop().toLowerCase();
        if (!allowed.includes(ext)) {
          alert("Unsupported file format. Please upload .csv, .xlsx, or .xls");
          excelInput.value = "";
          return;
        }
        const confirmed = confirm(
          `Are you sure you want to upload "${file.name}"?`
        );
        if (confirmed) {
          document.getElementById("uploadForm").submit();
        } else {
          excelInput.value = "";
        }
      }
    });
  }

  // Add event listener for SIC input to auto-fetch student data
  const sicInput = document.getElementById("candidateSic");
  if (sicInput) {
    let typingTimer;
    const doneTypingInterval = 800; // Wait 800ms after user stops typing

    sicInput.addEventListener("input", function () {
      clearTimeout(typingTimer);
      const sic = this.value.trim();

      if (sic.length > 0) {
        typingTimer = setTimeout(() => {
          fetchStudentData(sic);
        }, doneTypingInterval);
      } else {
        // Clear all fields if SIC is empty
        clearCandidateForm();
      }
    });
  }

  // Load candidates on page load
  loadCandidates();

  // Add event listeners to filter dropdowns
  const branchSelect = document.getElementById("candidateBranch");
  const sectionSelect = document.getElementById("candidateSection");
  const yearSelect = document.getElementById("candidateYear");

  if (branchSelect) {
    branchSelect.addEventListener("change", loadCandidates);
  }
  if (sectionSelect) {
    sectionSelect.addEventListener("change", loadCandidates);
  }
  if (yearSelect) {
    yearSelect.addEventListener("change", loadCandidates);
  }
});

// Function to open the Add Candidate modal
function openAddModal() {
  const modal = document.getElementById("addCandidateModal");
  if (modal) {
    modal.classList.add("active");
    clearCandidateForm();
  }
}

// Function to close the Add Candidate modal
function closeAddModal() {
  const modal = document.getElementById("addCandidateModal");
  if (modal) {
    modal.classList.remove("active");
    clearCandidateForm();
  }
}

// Function to clear the candidate form
function clearCandidateForm() {
  document.getElementById("candidateSic").value = "";
  document.getElementById("candidateRegCode").value = "";
  document.getElementById("candidateName").value = "";
  document.getElementById("candidateBranchInput").value = "";
  document.getElementById("candidateYearInput").value = "";
  document.getElementById("candidateSectionInput").value = "";
  document.getElementById("candidateMotiv").value = "";
  document.getElementById("photoContainer").style.display = "none";
  document.getElementById("photoPlaceholder").style.display = "block";
  document.getElementById("candidatePhoto").src = "";
  document.getElementById("sicError").style.display = "none";
  document.getElementById("sicError").textContent = "";
}

// Function to fetch student data by SIC
async function fetchStudentData(sic) {
  try {
    const response = await fetch(
      `getStudentBySic.jsp?sic=${encodeURIComponent(sic)}`
    );
    const data = await response.json();

    if (data.success) {
      // Populate form fields
      document.getElementById("candidateRegCode").value =
        data.reg_code || "Not generated yet";
      document.getElementById("candidateName").value = data.name || "";
      document.getElementById("candidateBranchInput").value = data.branch || "";
      document.getElementById("candidateYearInput").value = data.year || "";
      document.getElementById("candidateSectionInput").value =
        data.section || "";

      // Display photo if available
      if (data.image_url && data.image_url.trim() !== "") {
        document.getElementById("candidatePhoto").src = data.image_url;
        document.getElementById("photoContainer").style.display = "block";
        document.getElementById("photoPlaceholder").style.display = "none";
      } else {
        document.getElementById("photoContainer").style.display = "none";
        document.getElementById("photoPlaceholder").style.display = "block";
      }

      // Hide error message
      document.getElementById("sicError").style.display = "none";
    } else {
      // Show error message
      document.getElementById("sicError").textContent = data.message;
      document.getElementById("sicError").style.display = "block";

      // Clear other fields
      document.getElementById("candidateRegCode").value = "";
      document.getElementById("candidateName").value = "";
      document.getElementById("candidateBranchInput").value = "";
      document.getElementById("candidateYearInput").value = "";
      document.getElementById("candidateSectionInput").value = "";
      document.getElementById("photoContainer").style.display = "none";
      document.getElementById("photoPlaceholder").style.display = "block";
    }
  } catch (error) {
    console.error("Error fetching student data:", error);
    document.getElementById("sicError").textContent =
      "Error fetching student data. Please try again.";
    document.getElementById("sicError").style.display = "block";
  }
}

// Function to handle candidate submission
async function handleCandidateSubmit() {
  const sic = document.getElementById("candidateSic").value.trim();
  const motiv = document.getElementById("candidateMotiv").value.trim();
  const name = document.getElementById("candidateName").value.trim();
  const branch = document.getElementById("candidateBranchInput").value.trim();
  const year = document.getElementById("candidateYearInput").value.trim();
  const section = document.getElementById("candidateSectionInput").value.trim();

  // Validate required fields
  if (!sic || !motiv) {
    alert("Please fill in all required fields (SIC and Motivation)");
    return;
  }

  // Validate that student data was fetched
  if (!name || !branch) {
    alert("Please enter a valid SIC to fetch student details");
    return;
  }

  // Show confirmation dialog with CGPA check notice
  const confirmMessage =
    `Ready to register this candidate?\n\n` +
    `SIC: ${sic}\n` +
    `Name: ${name}\n` +
    `Branch: ${branch}\n` +
    `Year: ${year}\n` +
    `Section: ${section}\n\n` +
    `⚠️ CGPA Eligibility Check:\n` +
    `The system will now verify CGPA from ERP (minimum 8.5 required).\n` +
    `This may take 2-3 minutes. Please wait...\n\n` +
    `Click OK to proceed with verification.`;

  if (!confirm(confirmMessage)) {
    return;
  }

  // Create and show loading modal
  const loadingModal = document.createElement('div');
  loadingModal.id = 'cgpaCheckModal';
  loadingModal.className = 'modal active';
  loadingModal.innerHTML = `
    <div class="modal-content" style="max-width: 500px; text-align: center;">
      <div class="modal-header">
        <h2 class="modal-title">⏳ VERIFYING CGPA ELIGIBILITY</h2>
      </div>
      <div style="padding: 40px;">
        <p style="color: #8ab452; font-size: 16px; margin-bottom: 20px; font-weight: 700;">
          Checking CGPA for ${name}
        </p>
        <p style="color: #ffffff; font-size: 14px; margin-bottom: 10px;">
          SIC: ${sic}
        </p>
        <p style="color: #606060; font-size: 12px; margin-bottom: 20px;">
          Fetching from ERP system...
        </p>
        <div style="background: rgba(138, 180, 82, 0.1); padding: 20px; border-radius: 8px; margin-top: 20px;">
          <p style="color: #ff4757; font-size: 11px; font-weight: 700; margin-bottom: 5px;">
            ⚠️ This may take 2-3 minutes
          </p>
          <p style="color: #606060; font-size: 10px;">
            (Downloading and parsing result PDF from ERP)
          </p>
        </div>
        <div style="margin-top: 30px;">
          <div style="width: 100%; height: 4px; background: rgba(138, 180, 82, 0.2); border-radius: 2px; overflow: hidden;">
            <div style="width: 100%; height: 100%; background: #8ab452; animation: loading 2s ease-in-out infinite;"></div>
          </div>
        </div>
      </div>
    </div>
  `;
  document.body.appendChild(loadingModal);

  try {
    // Fetch CGPA from ERP
    const response = await fetch(`getCGPA.jsp?sic=${encodeURIComponent(sic)}`);
    const data = await response.json();

    // Remove loading modal
    loadingModal.remove();

    if (data.success && data.cgpa && data.cgpa !== "Not found") {
      const cgpaValue = parseFloat(data.cgpa);
      
      if (cgpaValue >= 8.5) {
        // Eligible - proceed with registration
        alert(`✅ CGPA VERIFIED: ${cgpaValue.toFixed(2)}\n\nCandidate is eligible (CGPA >= 8.5).\nProceeding with registration...`);
        
        // Set eligibility flag
        document.getElementById("isEligible").value = "true";
        
        // Submit to server
        const submitResponse = await fetch("registerCandidate.jsp", {
          method: "POST",
          headers: {
            "Content-Type": "application/x-www-form-urlencoded",
          },
          body: `sic=${encodeURIComponent(sic)}&motiv=${encodeURIComponent(motiv)}`,
        });

        const submitData = await submitResponse.json();

        if (submitData.success) {
          alert(submitData.message);
          closeAddModal();
          loadCandidates(); // Reload the candidate list
        } else {
          alert("Error: " + submitData.message);
        }
      } else {
        // Not eligible - show error
        alert(
          `❌ CANDIDATE NOT ELIGIBLE\n\n` +
          `CGPA: ${cgpaValue.toFixed(2)}\n` +
          `Minimum Required: 8.5\n\n` +
          `This student does not meet the minimum CGPA requirement for CR position.\n` +
          `Registration cannot proceed.`
        );
      }
    } else {
      // CGPA not found
      alert(
        `⚠️ CGPA NOT FOUND\n\n` +
        `Could not retrieve CGPA from ERP system for SIC: ${sic}\n\n` +
        `Possible reasons:\n` +
        `• Student has no results in ERP\n` +
        `• SIC is incorrect\n` +
        `• ERP system is down\n\n` +
        `Cannot proceed without CGPA verification.`
      );
    }
  } catch (error) {
    // Remove loading modal
    if (document.getElementById('cgpaCheckModal')) {
      document.getElementById('cgpaCheckModal').remove();
    }
    
    console.error("Error checking eligibility:", error);
    alert(
      `❌ ERROR CHECKING CGPA\n\n` +
      `${error.message}\n\n` +
      `Please ensure:\n` +
      `• Flask API is running (python app.py)\n` +
      `• ERP credentials are correct\n` +
      `• Network connection is stable\n\n` +
      `Cannot proceed without CGPA verification.`
    );
  }
}

// Function to animate counting from 0 to target value
function animateCount(element, target, duration = 1000) {
  const start = 0;
  const increment = target / (duration / 16); // 60fps
  let current = start;
  
  const timer = setInterval(() => {
    current += increment;
    if (current >= target) {
      element.textContent = target;
      clearInterval(timer);
    } else {
      element.textContent = Math.floor(current);
    }
  }, 16);
}

// Function to update statistics (Total Votes and Total Candidates)
function updateStatistics(candidates) {
  const totalVotesElement = document.getElementById("totalVotes");
  const totalCandidatesElement = document.getElementById("totalCandidates");

  if (!candidates || candidates.length === 0) {
    // No candidates found - animate to 0
    if (totalVotesElement) animateCount(totalVotesElement, 0, 500);
    if (totalCandidatesElement) animateCount(totalCandidatesElement, 0, 500);
    return;
  }

  // Calculate total votes by summing up votes from all candidates
  const totalVotes = candidates.reduce((sum, candidate) => sum + (candidate.votes || 0), 0);

  // Total candidates is just the length of the array
  const totalCandidates = candidates.length;

  // Update the display with animation
  if (totalVotesElement) animateCount(totalVotesElement, totalVotes, 1000);
  if (totalCandidatesElement) animateCount(totalCandidatesElement, totalCandidates, 1000);
}

// Function to load candidates based on filters
async function loadCandidates() {
  const branch = document.getElementById("candidateBranch").value;
  const section = document.getElementById("candidateSection").value;
  const year = document.getElementById("candidateYear").value;

  const candidateList = document.getElementById("candidateList");

  // Build the query parameters
  let queryParams = '';
  if (branch) queryParams += `branch=${encodeURIComponent(branch)}`;
  if (section) queryParams += (queryParams ? '&' : '') + `section=${encodeURIComponent(section)}`;
  if (year) queryParams += (queryParams ? '&' : '') + `year=${encodeURIComponent(year)}`;

  try {
    const response = await fetch(`getCandidates.jsp${queryParams ? '?' + queryParams : ''}`);
    const data = await response.json();

    if (data.success) {
      // Update the statistics
      updateStatistics(data.candidates);

      // Always display candidates (whether filtered or all)
      displayCandidates(data.candidates);
    } else {
      console.error("Error loading candidates:", data.message);
      candidateList.innerHTML = `
        <div style="text-align: center; padding: 40px; color: #ff4757;">
          <p style="font-size: 14px; text-transform: uppercase; letter-spacing: 2px;">Error loading candidates</p>
          <p style="font-size: 12px; margin-top: 10px;">${data.message}</p>
        </div>
      `;
    }
  } catch (error) {
    console.error("Error fetching candidates:", error);
    candidateList.innerHTML = `
      <div style="text-align: center; padding: 40px; color: #ff4757;">
        <p style="font-size: 14px; text-transform: uppercase; letter-spacing: 2px;">Connection Error</p>
        <p style="font-size: 12px; margin-top: 10px;">Unable to fetch candidates. Please try again.</p>
      </div>
    `;
  }
}

// Function to display candidates in the list
function displayCandidates(candidates) {
  const candidateList = document.getElementById("candidateList");

  // DEBUG: Log the data to console
  console.log("Candidates data:", candidates);

  if (candidates.length > 0) {
    console.log("First candidate image_url:", candidates[0].image_url);
  }

  if (candidates.length === 0) {
    candidateList.innerHTML = `
            <div style="text-align: center; padding: 40px; color: #606060;">
                <p style="font-size: 14px; text-transform: uppercase; letter-spacing: 2px;">No candidates found for the selected filters</p>
            </div>
        `;
    return;
  }

  candidateList.innerHTML = "";

  candidates.forEach((candidate, index) => {
    const candidateItem = document.createElement("div");
    candidateItem.className = "candidate-item";

    // DEBUG: Log each candidate's image URL
    console.log(`Candidate ${index + 1} - Name: ${candidate.name}, Image URL: ${candidate.image_url}`);

    // Determine what to show for avatar - photo or icon
    let avatarHTML = '';
    if (candidate.image_url && candidate.image_url.trim() !== '') {
      // Show actual photo
      avatarHTML = `<img src="${candidate.image_url}" alt="${candidate.name}" style="width: 50px; height: 50px; object-fit: cover; border: 1px solid #8ab452; clip-path: polygon(8px 0, 100% 0, 100% calc(100% - 8px), calc(100% - 8px) 100%, 0 100%, 0 8px);">`;
    } else {
      // Show default avatar
      avatarHTML = `<div class="candidate-avatar">👤</div>`;
    }

    candidateItem.innerHTML = `
            <div class="candidate-info">
                <div class="candidate-id">ID-${String(index + 1).padStart(3, "0")}</div>
                ${avatarHTML}
                <div class="candidate-details">
                    <h4>${candidate.name}</h4>
                    <p>${candidate.motiv || "No motivation provided"}</p>
                    <p style="font-size: 10px; margin-top: 5px;">
                        ${candidate.branch || 'N/A'} - Year ${candidate.year || 'N/A'} - Section ${candidate.section || 'N/A'}
                    </p>
                    <p style="font-size: 10px; margin-top: 3px;">SIC: ${candidate.sic} | Votes: ${candidate.votes}</p>
                </div>
            </div>
            <div class="candidate-actions">
                <button class="btn-icon" data-sic="${candidate.sic}" data-motiv="${candidate.motiv || ''}" onclick="editCandidateClick(this)" title="Edit Motivation">✎</button>
                <button class="btn-icon danger" onclick="deleteCandidate('${candidate.sic}', '${candidate.name}')" title="Delete Candidate">✕</button>
            </div>
        `;
    candidateList.appendChild(candidateItem);
  });
}

// Helper function to handle edit button click
function editCandidateClick(button) {
  const sic = button.getAttribute('data-sic');
  const currentMotiv = button.getAttribute('data-motiv');
  editCandidate(sic, currentMotiv);
}

// Function to edit candidate motivation
function editCandidate(sic, currentMotiv) {
  // Prompt for new motivation
  const newMotiv = prompt("Edit Motivation:\n\n(Current motivation shown below)", currentMotiv);

  // If user cancelled or entered empty text
  if (newMotiv === null || newMotiv.trim() === '') {
    return;
  }

  // Confirm the change
  const confirmed = confirm(`Are you sure you want to update the motivation?\n\nNew motivation:\n${newMotiv.substring(0, 200)}${newMotiv.length > 200 ? '...' : ''}`);

  if (!confirmed) {
    return;
  }

  // Send update request to server
  updateCandidateMotivation(sic, newMotiv);
}

// Function to update candidate motivation on server
async function updateCandidateMotivation(sic, newMotiv) {
  try {
    const response = await fetch('updateCandidateMotivation.jsp', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: `sic=${encodeURIComponent(sic)}&motiv=${encodeURIComponent(newMotiv)}`
    });

    const data = await response.json();

    if (data.success) {
      alert('Motivation updated successfully!');
      loadCandidates(); // Reload the candidate list
    } else {
      alert('Error: ' + data.message);
    }
  } catch (error) {
    console.error('Error updating motivation:', error);
    alert('Error updating motivation. Please try again.');
  }
}

// Function to delete candidate
async function deleteCandidate(sic, name) {
  const confirmed = confirm(
    `Are you sure you want to delete candidate ${name} (SIC: ${sic})?`
  );
  if (confirmed) {
    try {
      const response = await fetch("deleteCandidate.jsp", {
        method: "POST",
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: `sic=${encodeURIComponent(sic)}`,
      });

      const data = await response.json();

      if (data.success) {
        alert("Candidate deleted successfully!");
        loadCandidates(); // Reload the list
      } else {
        alert("Error: " + data.message);
      }
    } catch (error) {
      console.error("Error deleting candidate:", error);
      alert("Error deleting candidate. Please try again.");
    }
  }
}

// Reset Modal Functions
function openResetModal() {
  const modal = document.getElementById("resetModal");
  if (modal) {
    modal.classList.add("active");
    // Reset the modal to show warning first
    document.getElementById("resetWarning").style.display = "block";
    document.getElementById("resetConfirmation").style.display = "none";
    document.getElementById("resetConfirmationText").value = "";
    document.getElementById("confirmationError").style.display = "none";
  }
}

function closeResetModal() {
  const modal = document.getElementById("resetModal");
  if (modal) {
    modal.classList.remove("active");
    // Reset the modal state
    document.getElementById("resetWarning").style.display = "block";
    document.getElementById("resetConfirmation").style.display = "none";
    document.getElementById("resetConfirmationText").value = "";
    document.getElementById("confirmationError").style.display = "none";
  }
}

function showConfirmationInput() {
  // Hide warning and show confirmation input
  document.getElementById("resetWarning").style.display = "none";
  document.getElementById("resetConfirmation").style.display = "block";
}

async function executeReset() {
  const confirmationText = document.getElementById("resetConfirmationText").value;
  const expectedPhrase = "I am aware of the notes and I want to reset the dataset";

  // Check if the confirmation phrase matches
  if (confirmationText !== expectedPhrase) {
    document.getElementById("confirmationError").style.display = "block";
    return;
  }

  // Hide error if it was showing
  document.getElementById("confirmationError").style.display = "none";

  // Execute the reset
  try {
    const response = await fetch("resetDatabase.jsp", {
      method: "POST",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
    });

    const data = await response.json();

    if (data.success) {
      alert("Database reset successfully!\n\n" + data.message);
      closeResetModal();
      // Reload the page to reflect changes
      window.location.reload();
    } else {
      alert("Error resetting database: " + data.message);
    }
  } catch (error) {
    console.error("Error resetting database:", error);
    alert("Error resetting database. Please try again.");
  }
}

// Promote Modal Functions
function openPromoteModal() {
  const modal = document.getElementById("promoteModal");
  if (modal) {
    modal.classList.add("active");
    // Reset the modal to show filters first
    document.getElementById("promoteFilters").style.display = "block";
    document.getElementById("promoteWarning").style.display = "none";
    document.getElementById("promoteConfirmation").style.display = "none";
    document.getElementById("promoteBranch").value = "";
    document.getElementById("promoteSection").value = "";
    document.getElementById("promoteYear").value = "";
    document.getElementById("promoteConfirmationText").value = "";
    document.getElementById("promoteConfirmationError").style.display = "none";
  }
}

function closePromoteModal() {
  const modal = document.getElementById("promoteModal");
  if (modal) {
    modal.classList.remove("active");
    // Reset the modal state
    document.getElementById("promoteFilters").style.display = "block";
    document.getElementById("promoteWarning").style.display = "none";
    document.getElementById("promoteConfirmation").style.display = "none";
    document.getElementById("promoteBranch").value = "";
    document.getElementById("promoteSection").value = "";
    document.getElementById("promoteYear").value = "";
    document.getElementById("promoteConfirmationText").value = "";
    document.getElementById("promoteConfirmationError").style.display = "none";
  }
}

function showPromoteConfirmation() {
  const branch = document.getElementById("promoteBranch").value;
  const section = document.getElementById("promoteSection").value;
  const year = document.getElementById("promoteYear").value;
  
  // Build confirmation message
  let confirmText = "Are you sure you want to promote ";
  
  if (!branch && !section && !year) {
    confirmText += "ALL students to their respective next year?";
  } else {
    let filters = [];
    if (branch) filters.push(`Branch: ${branch}`);
    if (section) filters.push(`Section: ${section}`);
    if (year) filters.push(`Year: ${year}`);
    confirmText += `students (${filters.join(", ")}) to their next year?`;
  }
  
  document.getElementById("promoteConfirmText").textContent = confirmText;
  
  // Hide filters and show warning
  document.getElementById("promoteFilters").style.display = "none";
  document.getElementById("promoteWarning").style.display = "block";
}

function showPromoteTextInput() {
  // Hide warning and show text input
  document.getElementById("promoteWarning").style.display = "none";
  document.getElementById("promoteConfirmation").style.display = "block";
}

async function executePromote() {
  const confirmationText = document.getElementById("promoteConfirmationText").value;
  const expectedPhrase = "I am aware of the notes and I want to promote those students";
  
  // Check if the confirmation phrase matches
  if (confirmationText !== expectedPhrase) {
    document.getElementById("promoteConfirmationError").style.display = "block";
    return;
  }
  
  // Hide error if it was showing
  document.getElementById("promoteConfirmationError").style.display = "none";
  
  // Get filter values
  const branch = document.getElementById("promoteBranch").value;
  const section = document.getElementById("promoteSection").value;
  const year = document.getElementById("promoteYear").value;
  
  // Build query parameters
  let queryParams = '';
  if (branch) queryParams += `branch=${encodeURIComponent(branch)}`;
  if (section) queryParams += (queryParams ? '&' : '') + `section=${encodeURIComponent(section)}`;
  if (year) queryParams += (queryParams ? '&' : '') + `year=${encodeURIComponent(year)}`;
  
  // Execute the promote
  try {
    const response = await fetch(`promoteStudents.jsp${queryParams ? '?' + queryParams : ''}`, {
      method: "POST",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
    });
    
    const data = await response.json();
    
    if (data.success) {
      alert("Students promoted successfully!\n\n" + data.message);
      closePromoteModal();
      // Reload the page to reflect changes
      window.location.reload();
    } else {
      alert("Error promoting students: " + data.message);
    }
  } catch (error) {
    console.error("Error promoting students:", error);
    alert("Error promoting students. Please try again.");
  }
}

// ============================================
// RESULTS FEATURE FUNCTIONS
// ============================================

// Global variable to store tied candidates data
let tiedCandidatesData = [];

// Function to open results modal
function openResultsModal() {
  const modal = document.getElementById("resultsModal");
  if (modal) {
    modal.classList.add("active");
    // Reset selections
    document.getElementById("resultsBranch").value = "";
    document.getElementById("resultsSection").value = "";
    document.getElementById("resultsYear").value = "";
  }
}

// Function to close results modal
function closeResultsModal() {
  const modal = document.getElementById("resultsModal");
  if (modal) {
    modal.classList.remove("active");
  }
}

// Function to fetch winner based on selected filters
async function fetchWinner() {
  const branch = document.getElementById("resultsBranch").value;
  const section = document.getElementById("resultsSection").value;
  const year = document.getElementById("resultsYear").value;
  
  // Validate that all fields are selected
  if (!branch || !section || !year) {
    alert("Please select Branch, Section, and Year to view results.");
    return;
  }
  
  try {
    console.log("Fetching winner for:", { branch, section, year });
    const url = `getWinner.jsp?branch=${encodeURIComponent(branch)}&section=${encodeURIComponent(section)}&year=${encodeURIComponent(year)}`;
    console.log("Request URL:", url);
    
    const response = await fetch(url);
    console.log("Response status:", response.status);
    console.log("Response OK:", response.ok);
    
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    
    const responseText = await response.text();
    console.log("Response text:", responseText);
    
    const data = JSON.parse(responseText);
    console.log("Parsed data:", data);
    
    if (data.success) {
      if (data.candidates.length === 0) {
        alert("No candidates found for the selected filters.");
        return;
      }
      
      // Check if there's a tie
      if (data.isTie) {
        // Store tied candidates data
        tiedCandidatesData = data.candidates;
        // Show tie-breaking modal
        closeResultsModal();
        showTieBreakModal(data.candidates);
      } else {
        // Single winner - show certificate directly
        closeResultsModal();
        showCertificate(data.candidates[0], data.totalVotes);
      }
    } else {
      alert("Error fetching results: " + data.message);
    }
  } catch (error) {
    console.error("Error details:", error);
    console.error("Error message:", error.message);
    console.error("Error stack:", error.stack);
    alert("Error fetching results: " + error.message + "\n\nCheck browser console (F12) for details.");
  }
}

// Function to show tie-breaking modal with automatic CGPA fetching
async function showTieBreakModal(candidates) {
  const modal = document.getElementById("tieBreakModal");
  const candidatesList = document.getElementById("tiedCandidatesList");
  
  // Show loading message
  candidatesList.innerHTML = `
    <div style="text-align: center; padding: 40px; color: #8ab452;">
      <p style="font-size: 16px; text-transform: uppercase; letter-spacing: 2px; margin-bottom: 15px;">⏳ Fetching CGPA Data...</p>
      <p style="font-size: 12px; color: #606060; margin-bottom: 10px;">Please wait while we retrieve CGPA from ERP system</p>
      <p style="font-size: 11px; color: #ff4757; font-weight: 700;">⚠️ This may take 2-3 minutes per candidate</p>
      <p style="font-size: 10px; color: #606060; margin-top: 5px;">(Downloading and parsing result PDFs from ERP)</p>
    </div>
  `;
  
  modal.classList.add("active");
  
  // Fetch CGPA for all candidates
  const candidatesWithCGPA = [];
  let fetchErrors = [];
  
  for (let i = 0; i < candidates.length; i++) {
    const candidate = candidates[i];
    
    // Update progress message
    candidatesList.innerHTML = `
      <div style="text-align: center; padding: 40px; color: #8ab452;">
        <p style="font-size: 16px; text-transform: uppercase; letter-spacing: 2px; margin-bottom: 15px;">⏳ Fetching CGPA Data...</p>
        <p style="font-size: 14px; color: #8ab452; font-weight: 700; margin-bottom: 10px;">Processing ${i + 1} of ${candidates.length}</p>
        <p style="font-size: 12px; color: #ffffff; margin-bottom: 5px;">Current: ${candidate.name} (${candidate.sic})</p>
        <p style="font-size: 11px; color: #ff4757; font-weight: 700; margin-top: 15px;">⚠️ This may take 2-3 minutes per candidate</p>
        <p style="font-size: 10px; color: #606060; margin-top: 5px;">(Downloading and parsing result PDFs from ERP)</p>
      </div>
    `;
    
    try {
      const response = await fetch(`getCGPA.jsp?sic=${encodeURIComponent(candidate.sic)}`);
      const data = await response.json();
      
      if (data.success && data.cgpa && data.cgpa !== "Not found") {
        const cgpaValue = parseFloat(data.cgpa);
        candidatesWithCGPA.push({
          ...candidate,
          cgpa: cgpaValue,
          cgpaFetched: true
        });
      } else {
        candidatesWithCGPA.push({
          ...candidate,
          cgpa: null,
          cgpaFetched: false,
          error: "CGPA not found in ERP"
        });
        fetchErrors.push(`${candidate.name} (${candidate.sic}): CGPA not found`);
      }
    } catch (error) {
      candidatesWithCGPA.push({
        ...candidate,
        cgpa: null,
        cgpaFetched: false,
        error: error.message
      });
      fetchErrors.push(`${candidate.name} (${candidate.sic}): ${error.message}`);
    }
  }
  
  // Build the candidates list HTML with fetched CGPA
  let html = '';
  
  // Check if all CGPAs were fetched successfully
  const allFetched = candidatesWithCGPA.every(c => c.cgpaFetched);
  
  if (allFetched) {
    // All candidates are already eligible (checked at registration)
    // Sort by CGPA descending
    candidatesWithCGPA.sort((a, b) => b.cgpa - a.cgpa);
    
    // Check if there's a tie in CGPA
    const highestCGPA = candidatesWithCGPA[0].cgpa;
    const topCandidates = candidatesWithCGPA.filter(c => c.cgpa === highestCGPA);
    
    if (topCandidates.length === 1) {
      // Clear winner found - auto-proceed to certificate
      const winner = topCandidates[0];
      
      // Store winner for certificate display
      tiedCandidatesData = [winner];
      
      // Close modal and show certificate directly
      closeTieBreakModal();
      const totalVotes = candidates.reduce((sum, c) => sum + c.votes, 0);
      showCertificate(winner, totalVotes);
      
    } else {
      // Still a tie - show all candidates with same highest CGPA
      html += `
        <div style="background: rgba(255, 193, 7, 0.1); border: 1px solid #ffc107; padding: 15px; margin-bottom: 20px; border-radius: 8px;">
          <p style="color: #ffc107; font-weight: 700; margin-bottom: 10px;">⚠️ TIE PERSISTS</p>
          <p style="color: #ffffff; font-size: 12px;">Multiple candidates have the same highest CGPA (${highestCGPA.toFixed(2)}). Manual selection required.</p>
        </div>
      `;
      
      candidatesWithCGPA.forEach((candidate, index) => {
        const isTopCandidate = candidate.cgpa === highestCGPA;
        const borderColor = isTopCandidate ? '#ffc107' : 'rgba(138, 180, 82, 0.3)';
        
        html += `
          <div class="candidate-cgpa-card" style="border: 2px solid ${borderColor};">
            <div style="display: grid; grid-template-columns: 80px 1fr; gap: 20px; margin-bottom: 15px;">
              <img src="${candidate.image_url || 'default-avatar.png'}" alt="${candidate.name}" 
                   style="width: 80px; height: 80px; object-fit: cover; border: 2px solid ${borderColor}; clip-path: polygon(10px 0, 100% 0, 100% calc(100% - 10px), calc(100% - 10px) 100%, 0 100%, 0 10px);">
              <div>
                <h3 style="color: ${isTopCandidate ? '#ffc107' : '#ffffff'}; font-family: 'Orbitron', sans-serif; font-size: 16px; margin-bottom: 5px;">
                  ${candidate.name}
                </h3>
                <p style="color: #ffffff; font-size: 12px; margin-bottom: 3px;">SIC: ${candidate.sic}</p>
                <p style="color: #ffffff; font-size: 12px; margin-bottom: 3px;">Registration: ${candidate.reg_code}</p>
                <p style="color: #8ab452; font-size: 14px; font-weight: 700; margin-top: 5px;">Votes: ${candidate.votes}</p>
              </div>
            </div>
            
            <div style="background: rgba(0, 0, 0, 0.3); padding: 15px; border-radius: 5px; margin-top: 10px;">
              <p style="color: #8ab452; font-size: 14px; font-weight: 700; font-family: 'Orbitron', sans-serif;">
                CGPA: ${candidate.cgpa.toFixed(2)}
              </p>
            </div>
          </div>
        `;
      });
      
      candidatesList.innerHTML = html;
    }
    
  } else {
    // Some CGPAs couldn't be fetched - show error and manual input
    if (fetchErrors.length > 0) {
      html += `
        <div style="background: rgba(255, 71, 87, 0.1); border: 1px solid #ff4757; padding: 15px; margin-bottom: 20px; border-radius: 8px;">
          <p style="color: #ff4757; font-weight: 700; margin-bottom: 10px;">⚠️ CGPA FETCH ERRORS</p>
          <p style="color: #ffffff; font-size: 12px; margin-bottom: 10px;">Could not automatically fetch CGPA for some candidates:</p>
          ${fetchErrors.map(err => `<p style="color: #ff4757; font-size: 11px; margin-top: 3px;">• ${err}</p>`).join('')}
          <p style="color: #ffffff; font-size: 12px; margin-top: 10px;">Please enter CGPA manually below:</p>
        </div>
      `;
    }
    
    candidatesWithCGPA.forEach((candidate, index) => {
      const hasCGPA = candidate.cgpaFetched;
      
      html += `
        <div class="candidate-cgpa-card">
          <div style="display: grid; grid-template-columns: 80px 1fr; gap: 20px; margin-bottom: 15px;">
            <img src="${candidate.image_url || 'default-avatar.png'}" alt="${candidate.name}" 
                 style="width: 80px; height: 80px; object-fit: cover; border: 2px solid #8ab452; clip-path: polygon(10px 0, 100% 0, 100% calc(100% - 10px), calc(100% - 10px) 100%, 0 100%, 0 10px);">
            <div>
              <h3 style="color: #8ab452; font-family: 'Orbitron', sans-serif; font-size: 16px; margin-bottom: 5px;">${candidate.name}</h3>
              <p style="color: #ffffff; font-size: 12px; margin-bottom: 3px;">SIC: ${candidate.sic}</p>
              <p style="color: #ffffff; font-size: 12px; margin-bottom: 3px;">Registration: ${candidate.reg_code}</p>
              <p style="color: #8ab452; font-size: 14px; font-weight: 700; margin-top: 5px;">Votes: ${candidate.votes}</p>
            </div>
          </div>
          
          <div class="cgpa-input-group">
            <div class="form-group" style="margin-bottom: 0;">
              <label class="form-label">${hasCGPA ? 'CGPA (Auto-fetched)' : 'ENTER CGPA MANUALLY'}</label>
              <input type="number" step="0.01" min="0" max="10" class="form-input" id="cgpa_${index}" 
                     placeholder="Enter CGPA (0.00 - 10.00)" value="${hasCGPA ? candidate.cgpa.toFixed(2) : ''}" 
                     ${hasCGPA ? 'readonly style="background: rgba(138, 180, 82, 0.2);"' : ''} data-candidate-index="${index}">
            </div>
          </div>
          
          <div class="checkbox-confirm" id="confirm_${index}" style="${hasCGPA ? 'display: flex;' : 'display: none;'}">
            <input type="checkbox" id="checkbox_${index}" data-candidate-index="${index}" ${hasCGPA ? 'checked' : ''}>
            <label for="checkbox_${index}">I have verified this CGPA ${hasCGPA ? '(auto-fetched from ERP)' : 'from the ERP system'} and confirm it is accurate.</label>
          </div>
        </div>
      `;
    });
    
    candidatesList.innerHTML = html;
    
    // Add event listeners to manual CGPA inputs
    candidatesWithCGPA.forEach((candidate, index) => {
      if (!candidate.cgpaFetched) {
        const input = document.getElementById(`cgpa_${index}`);
        if (input) {
          input.addEventListener('input', function() {
            const confirmDiv = document.getElementById(`confirm_${index}`);
            if (this.value && this.value.trim() !== '') {
              confirmDiv.style.display = 'flex';
            } else {
              confirmDiv.style.display = 'none';
              document.getElementById(`checkbox_${index}`).checked = false;
            }
          });
        }
      }
    });
  }
}

// Function to close tie-breaking modal
function closeTieBreakModal() {
  const modal = document.getElementById("tieBreakModal");
  if (modal) {
    modal.classList.remove("active");
  }
}

// Function to determine winner from tied candidates
function determineTieWinner() {
  // Collect CGPA data for all candidates
  let candidatesWithCGPA = [];
  let allConfirmed = true;
  
  tiedCandidatesData.forEach((candidate, index) => {
    const cgpaInput = document.getElementById(`cgpa_${index}`);
    const checkbox = document.getElementById(`checkbox_${index}`);
    
    const cgpa = parseFloat(cgpaInput.value);
    
    if (!cgpaInput.value || isNaN(cgpa)) {
      alert(`Please enter CGPA for ${candidate.name}`);
      allConfirmed = false;
      return;
    }
    
    if (!checkbox.checked) {
      alert(`Please confirm that you have verified the CGPA for ${candidate.name}`);
      allConfirmed = false;
      return;
    }
    
    candidatesWithCGPA.push({
      ...candidate,
      cgpa: cgpa
    });
  });
  
  if (!allConfirmed) {
    return;
  }
  
  // Sort by CGPA descending
  candidatesWithCGPA.sort((a, b) => b.cgpa - a.cgpa);
  
  // Check if there's still a tie in CGPA
  if (candidatesWithCGPA.length > 1 && candidatesWithCGPA[0].cgpa === candidatesWithCGPA[1].cgpa) {
    alert("There is still a tie! Multiple candidates have the same CGPA. Please verify the data.");
    return;
  }
  
  // Winner is the one with highest CGPA
  const winner = candidatesWithCGPA[0];
  
  // Calculate total votes
  const totalVotes = tiedCandidatesData.reduce((sum, c) => sum + c.votes, 0);
  
  // Close tie-break modal and show certificate
  closeTieBreakModal();
  showCertificate(winner, totalVotes);
}

// Function to show certificate with countdown
function showCertificate(winner, totalVotes) {
  const overlay = document.getElementById("certificateOverlay");
  const countdownContainer = document.getElementById("countdownContainer");
  const certificateContainer = document.getElementById("certificateContainer");
  const countdownNumber = document.getElementById("countdownNumber");
  
  // Show overlay
  overlay.classList.add("active");
  
  // Show countdown
  countdownContainer.style.display = "block";
  certificateContainer.classList.remove("active");
  
  // Start countdown from 5 to 1
  let count = 5;
  countdownNumber.textContent = count;
  
  const countdownInterval = setInterval(() => {
    count--;
    if (count > 0) {
      countdownNumber.textContent = count;
      // Re-trigger animation
      countdownNumber.style.animation = 'none';
      setTimeout(() => {
        countdownNumber.style.animation = 'countdownPulse 1s ease-in-out';
      }, 10);
    } else {
      clearInterval(countdownInterval);
      // Hide countdown and show certificate
      countdownContainer.style.display = "none";
      displayCertificateContent(winner, totalVotes);
      certificateContainer.classList.add("active");
      
      // Trigger confetti
      triggerConfetti();
    }
  }, 1000);
}

// Function to display certificate content
function displayCertificateContent(winner, totalVotes) {
  // Set winner photo
  document.getElementById("winnerPhoto").src = winner.image_url || 'default-avatar.png';
  
  // Set winner details
  document.getElementById("winnerName").textContent = winner.name;
  document.getElementById("winnerSic").textContent = winner.sic;
  document.getElementById("winnerBranch").textContent = winner.branch;
  document.getElementById("winnerSection").textContent = winner.section;
  document.getElementById("winnerYear").textContent = winner.year;
  
  // Set vote count
  document.getElementById("winnerVotes").textContent = winner.votes;
  
  // Calculate vote margin
  const otherVotes = totalVotes - winner.votes;
  const margin = winner.votes - (otherVotes > 0 ? Math.floor(otherVotes / (tiedCandidatesData.length > 1 ? tiedCandidatesData.length - 1 : 1)) : 0);
  
  if (margin > 0) {
    document.getElementById("voteMargin").textContent = `Won by ${margin} vote${margin !== 1 ? 's' : ''} margin`;
  } else {
    document.getElementById("voteMargin").textContent = `Secured ${winner.votes} vote${winner.votes !== 1 ? 's' : ''}`;
  }
}

// Function to trigger confetti animation
function triggerConfetti() {
  const overlay = document.getElementById("certificateOverlay");
  const colors = ['#8ab452', '#9fc961', '#7da042', '#6b8f3a', '#ffffff'];
  
  // Create confetti across entire screen width
  for (let i = 0; i < 80; i++) {
    setTimeout(() => {
      createConfetti(overlay, colors[Math.floor(Math.random() * colors.length)]);
    }, i * 25);
  }
  
  // Stop creating confetti after 2 seconds
  setTimeout(() => {
    // Confetti creation stops here
  }, 2000);
}

// Function to create individual confetti piece
function createConfetti(container, color) {
  const confetti = document.createElement('div');
  confetti.className = 'confetti';
  confetti.style.background = color;
  confetti.style.width = (Math.random() * 8 + 6) + 'px';
  confetti.style.height = (Math.random() * 8 + 6) + 'px';
  
  // Random position across entire width
  confetti.style.left = (Math.random() * 100) + '%';
  confetti.style.bottom = '0';
  confetti.style.animation = `confettiFall ${2 + Math.random()}s linear`;
  
  container.appendChild(confetti);
  
  // Remove confetti after animation (2-3 seconds)
  setTimeout(() => {
    confetti.remove();
  }, 3000);
}

// Function to close certificate
function closeCertificate() {
  const overlay = document.getElementById("certificateOverlay");
  overlay.classList.remove("active");
  
  // Reset for next use
  const certificateContainer = document.getElementById("certificateContainer");
  certificateContainer.classList.remove("active");
  
  // Clear tied candidates data
  tiedCandidatesData = [];
}

// ============================================
// DELETE DATA FEATURE FUNCTIONS
// ============================================

// Function to open delete data modal
function openDeleteDataModal() {
  const modal = document.getElementById("deleteDataModal");
  if (modal) {
    modal.classList.add("active");
    // Reset the modal to show filters first
    document.getElementById("deleteFilters").style.display = "block";
    document.getElementById("deleteWarning").style.display = "none";
    document.getElementById("deleteConfirmation").style.display = "none";
    document.getElementById("deleteBranch").value = "";
    document.getElementById("deleteSection").value = "";
    document.getElementById("deleteYear").value = "";
    document.getElementById("deleteConfirmationText").value = "";
    document.getElementById("deleteConfirmationError").style.display = "none";
  }
}

// Function to close delete data modal
function closeDeleteDataModal() {
  const modal = document.getElementById("deleteDataModal");
  if (modal) {
    modal.classList.remove("active");
    // Reset the modal state
    document.getElementById("deleteFilters").style.display = "block";
    document.getElementById("deleteWarning").style.display = "none";
    document.getElementById("deleteConfirmation").style.display = "none";
    document.getElementById("deleteBranch").value = "";
    document.getElementById("deleteSection").value = "";
    document.getElementById("deleteYear").value = "";
    document.getElementById("deleteConfirmationText").value = "";
    document.getElementById("deleteConfirmationError").style.display = "none";
  }
}

// Function to show delete warning
function showDeleteWarning() {
  const branch = document.getElementById("deleteBranch").value;
  const section = document.getElementById("deleteSection").value;
  const year = document.getElementById("deleteYear").value;
  
  // Build confirmation message
  let confirmText = "You are about to delete ";
  
  if (!branch && !section && !year) {
    confirmText += "ALL students and candidates from the entire database. This will completely clear both the students and candidates tables.";
  } else {
    let filters = [];
    if (branch) filters.push(`Branch: ${branch}`);
    if (section) filters.push(`Section: ${section}`);
    if (year) filters.push(`Year: ${year}`);
    confirmText += `students and candidates matching the following criteria: ${filters.join(", ")}. Only records matching these filters will be permanently deleted.`;
  }
  
  document.getElementById("deleteConfirmText").textContent = confirmText;
  
  // Hide filters and show warning
  document.getElementById("deleteFilters").style.display = "none";
  document.getElementById("deleteWarning").style.display = "block";
}

// Function to show delete text input
function showDeleteTextInput() {
  // Hide warning and show text input
  document.getElementById("deleteWarning").style.display = "none";
  document.getElementById("deleteConfirmation").style.display = "block";
}

// Function to execute delete
async function executeDelete() {
  const confirmationText = document.getElementById("deleteConfirmationText").value;
  const expectedPhrase = "I want to delete the data and I know this cannot be undone";
  
  // Check if the confirmation phrase matches
  if (confirmationText !== expectedPhrase) {
    document.getElementById("deleteConfirmationError").style.display = "block";
    return;
  }
  
  // Hide error if it was showing
  document.getElementById("deleteConfirmationError").style.display = "none";
  
  // Get filter values
  const branch = document.getElementById("deleteBranch").value;
  const section = document.getElementById("deleteSection").value;
  const year = document.getElementById("deleteYear").value;
  
  // Build query parameters
  let queryParams = '';
  if (branch) queryParams += `branch=${encodeURIComponent(branch)}`;
  if (section) queryParams += (queryParams ? '&' : '') + `section=${encodeURIComponent(section)}`;
  if (year) queryParams += (queryParams ? '&' : '') + `year=${encodeURIComponent(year)}`;
  
  // Execute the delete
  try {
    const response = await fetch(`deleteData.jsp${queryParams ? '?' + queryParams : ''}`, {
      method: "POST",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
    });
    
    const data = await response.json();
    
    if (data.success) {
      alert("Data deleted successfully!\n\n" + data.message);
      closeDeleteDataModal();
      // Reload the page to reflect changes
      window.location.reload();
    } else {
      alert("Error deleting data: " + data.message);
    }
  } catch (error) {
    console.error("Error deleting data:", error);
    alert("Error deleting data. Please try again.");
  }
}
