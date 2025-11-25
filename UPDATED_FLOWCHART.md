---
config:
  layout: elk
  theme: dark
---
flowchart TB
    subgraph Landing["🏠 LANDING PAGE"]
        direction TB
        Start(("👤 User Visits<br/>index.html"))
        LoadStats["⚡ Auto-Load Stats<br/>getStats.jsp"]
        DisplayStats["📊 Display Live Stats:<br/>• Total Students<br/>• Candidates<br/>• Sections<br/>• Participation %"]
        ChoosePortal{"Select Portal"}
    end

    subgraph Student_Portal["🎓 STUDENT PORTAL"]
        direction TB
        S_Auth["📝 Student Login<br/>studentAuth.html"]
        S_InputSIC["Enter SIC"]
        AuthJSP["🔐 Authenticate<br/>authenticateStudent.jsp"]
        DB_Check_Stu{"✓ Student<br/>Exists?"}
        Check_Voted{"Already<br/>Voted?<br/>(isVoted=1)"}
        Err_NotFound["❌ Error:<br/>Student Not Found"]
        Err_Voted["⚠️ Error:<br/>Already Voted"]
        CreateSession["✅ Create Session<br/>Store: SIC, Name,<br/>Branch, Section,<br/>Year, ImageUrl"]
        
        VotePage["🗳️ Voting Interface<br/>voting.html"]
        LoadStudentData["📥 Load Student Data<br/>getStudentData.jsp"]
        DisplayStudentInfo["👤 Display:<br/>Name, SIC,<br/>Branch, Section, Year"]
        LoadCand["📋 Load Candidates<br/>JS: loadCandidates()"]
        FetchCand["🔍 Fetch Candidates<br/>getCandidates.jsp"]
        FilterCand["🎯 Filter by:<br/>Branch, Section, Year"]
        DisplayCand["🎴 Display Candidate Cards"]
        
        SelectCandidate["👆 Click VOTE Button"]
        ConfirmVote{"Confirm Vote?"}
        CancelVote["❌ Cancel"]
        CastScript["📤 Cast Vote<br/>JS: castVote()"]
        CastJSP["💾 Process Vote<br/>castVote.jsp"]
        ValidateMatch{"Validate:<br/>Same Branch/<br/>Section/Year?"}
        ReturnErr["❌ Return Error JSON"]
        StartTransaction["🔄 Start DB Transaction"]
        UpdateVoteCount["➕ Increment Candidate Votes"]
        MarkVoted["✓ Set Student isVoted=1"]
        CommitTrans["✅ Commit Transaction"]
        ReturnSuccess["✅ Return Success JSON"]
        ShowSuccess["🎉 Show Success Message<br/>Disable Vote Buttons"]
        LogoutStudent["🚪 Logout"]
    end

    subgraph Admin_Portal["⚙️ ADMIN PORTAL"]
        direction TB
        A_Auth["🔑 Admin Login<br/>adminauth.html"]
        A_InputCreds["Enter ID & Key"]
        JS_Val{"Validate:<br/>ID=2323<br/>Key=1234"}
        Shake["❌ Shake Animation<br/>Invalid Credentials"]
        
        AdminDash["📊 Admin Dashboard<br/>admin.html"]
        LoadAdminStats["📈 Load Statistics<br/>getStats.jsp"]
        DisplayAdminStats["📊 Show:<br/>Total Students,<br/>Candidates, Sections,<br/>Participation %"]
        
        TabNav{"📑 Select Tab"}
        
        subgraph Tab_Candidates["📋 CANDIDATES TAB"]
            direction TB
            CandFilters["🔍 Filter Controls:<br/>Branch, Section, Year"]
            LoadCandList["📥 Load Candidates<br/>getCandidates.jsp"]
            DisplayCandList["🎴 Display Candidate List"]
            
            AddCandBtn["➕ Add Candidate"]
            ModalAdd["📝 Add Candidate Modal"]
            InputSIC["Enter Student SIC"]
            FetchStu["🔍 Fetch Student<br/>getStudentBySic.jsp"]
            ShowStuInfo["👤 Display:<br/>Name, Image, Branch"]
            InputMotivation["✍️ Enter Motivation"]
            SubmitCandidate["💾 Submit"]
            RegCand["📥 Register Candidate<br/>registerCandidate.jsp"]
            DB_AddCand[("💾 INSERT INTO<br/>candidates")]
            
            EditCandBtn["✏️ Edit Candidate"]
            ModalEdit["📝 Edit Motivation Modal"]
            ShowBeforeAfter["📋 Show Before/After<br/>Confirmation"]
            ConfirmUpdate{"Confirm<br/>Update?"}
            UpdMot["💾 Update Motivation<br/>updateCandidateMotivation.jsp"]
            DB_Upd[("💾 UPDATE<br/>candidates")]
            
            DelCandBtn["🗑️ Delete Candidate"]
            ConfirmDelete{"Confirm<br/>Delete?"}
            DelCand["🗑️ Delete Candidate<br/>deleteCandidate.jsp"]
            DB_Del[("💾 DELETE FROM<br/>candidates")]
        end
        
        subgraph Tab_Import["📤 IMPORT DATA TAB"]
            direction TB
            ImportBtn["📁 Import Excel/CSV"]
            FileDialog["📂 File Explorer<br/>(.xlsx, .xls, .csv)"]
            SelectFile["📄 Select File"]
            UploadJSP["⬆️ Upload & Process<br/>upload.jsp"]
            ParseFile{"Parse File<br/>Type?"}
            ParseCSV["📊 Parse CSV<br/>CSVReader"]
            ParseXLSX["📊 Parse XLSX<br/>XSSFWorkbook"]
            ParseXLS["📊 Parse XLS<br/>HSSFWorkbook"]
            ValidateRows["✓ Validate Rows:<br/>9 Columns Required"]
            ValidateYear["✓ Validate Year:<br/>Integer 1-4"]
            BatchInsert["💾 Batch Insert<br/>Students Table"]
            ShowUploadResult["📊 Show Results:<br/>Success/Failed Count"]
            HandleStrictOOXML["⚠️ Handle Strict OOXML<br/>Error Message"]
        end
        
        subgraph Tab_Results["🏆 RESULTS TAB"]
            direction TB
            ViewResultsBtn["🏆 View Results"]
            WinJSP["🔍 Calculate Winner<br/>getWinner.jsp"]
            QueryMaxVotes["📊 Query Max Votes"]
            TieCheck{"Tie<br/>Detected?"}
            ShowWinner["🎉 Display Winner:<br/>Name, SIC, Votes,<br/>Branch, Section"]
            TieModal["⚖️ Tie-Breaker Modal"]
            InputCGPA["📝 Enter CGPA Values"]
            CalcTieBreaker["🧮 Calculate Winner<br/>by CGPA"]
            DisplayTieWinner["🎉 Display Tie Winner"]
        end
        
        subgraph Tab_Promote["⬆️ PROMOTE STUDENTS"]
            direction TB
            PromoteBtn["⬆️ Promote Students"]
            PromoteModal["📝 Promote Modal"]
            PromoteFilters["🔍 Optional Filters:<br/>Branch, Section, Year"]
            PromoteWarning["⚠️ Warning Message:<br/>Irreversible Action"]
            ConfirmPromote{"Confirm<br/>Promotion?"}
            PromoJSP["⬆️ Promote Students<br/>promoteStudents.jsp"]
            DB_Promo[("💾 UPDATE students<br/>SET year = year + 1")]
            ShowPromoResult["✅ Show Promotion<br/>Success Message"]
        end
        
        subgraph Tab_Delete["🗑️ DELETE DATA"]
            direction TB
            DeleteBtn["🗑️ Delete Data"]
            DeleteModal["⚠️ Delete Data Modal"]
            DeleteFilters["🔍 Optional Filters:<br/>Branch, Section, Year"]
            DeleteWarning["⚠️ WARNING:<br/>Permanent Data Loss!"]
            TypeConfirm["⌨️ Type 'DELETE'<br/>to Confirm"]
            ValidateText{"Text<br/>Matches?"}
            EnableDeleteBtn["✅ Enable Delete Button"]
            ConfirmDeleteData{"Final<br/>Confirm?"}
            DeleteJSP["🗑️ Delete Data<br/>deleteData.jsp"]
            DB_DeleteStu[("💾 DELETE FROM<br/>students")]
            DB_DeleteCand[("💾 DELETE FROM<br/>candidates")]
            ShowDeleteResult["✅ Show Deletion<br/>Results"]
        end
        
        subgraph Tab_Reset["🔄 RESET DATABASE"]
            direction TB
            ResetBtn["🔄 Reset Database"]
            ResetWarning["⚠️ WARNING:<br/>Reset All Votes!"]
            ConfirmReset{"Confirm<br/>Reset?"}
            ResetJSP["🔄 Reset Database<br/>resetDatabase.jsp"]
            DB_ResetVotes[("💾 UPDATE students<br/>SET isVoted = 0")]
            DB_ClearCand[("💾 DELETE FROM<br/>candidates")]
            ShowResetResult["✅ Show Reset<br/>Success Message"]
        end
        
        LogoutAdmin["🚪 Logout Admin"]
    end

    subgraph Database["🗄️ MYSQL DATABASE"]
        direction LR
        T_Students[("📚 TABLE: students<br/>────────────<br/>• serial_no<br/>• roll_no<br/>• sic (PK)<br/>• reg_code<br/>• image_url<br/>• name<br/>• branch<br/>• section<br/>• year (INT)<br/>• isVoted")]
        T_Candidates[("🎯 TABLE: candidates<br/>────────────<br/>• id (PK)<br/>• sic (FK)<br/>• name<br/>• image_url<br/>• branch<br/>• section<br/>• year<br/>• motivation<br/>• votes")]
    end

    %% Landing Page Flow
    Start --> LoadStats
    LoadStats --> DisplayStats
    DisplayStats --> ChoosePortal
    ChoosePortal -- "Click 'START VOTING'" --> S_Auth
    ChoosePortal -- "Click 'ADMIN'" --> A_Auth

    %% Student Authentication Flow
    S_Auth --> S_InputSIC
    S_InputSIC --> AuthJSP
    AuthJSP --> DB_Check_Stu
    DB_Check_Stu -- "No" --> Err_NotFound
    Err_NotFound --> S_Auth
    DB_Check_Stu -- "Yes" --> Check_Voted
    Check_Voted -- "Yes (isVoted=1)" --> Err_Voted
    Err_Voted --> S_Auth
    Check_Voted -- "No (isVoted=0)" --> CreateSession
    CreateSession --> VotePage

    %% Voting Flow
    VotePage --> LoadStudentData
    LoadStudentData --> DisplayStudentInfo
    VotePage --> LoadCand
    LoadCand --> FetchCand
    FetchCand --> FilterCand
    FilterCand --> DisplayCand
    DisplayCand --> SelectCandidate
    SelectCandidate --> ConfirmVote
    ConfirmVote -- "No" --> CancelVote
    CancelVote --> DisplayCand
    ConfirmVote -- "Yes" --> CastScript
    CastScript --> CastJSP
    CastJSP --> ValidateMatch
    ValidateMatch -- "No" --> ReturnErr
    ReturnErr --> DisplayCand
    ValidateMatch -- "Yes" --> StartTransaction
    StartTransaction --> UpdateVoteCount
    UpdateVoteCount --> MarkVoted
    MarkVoted --> CommitTrans
    CommitTrans --> ReturnSuccess
    ReturnSuccess --> ShowSuccess
    VotePage --> LogoutStudent
    LogoutStudent --> Start

    %% Admin Authentication Flow
    A_Auth --> A_InputCreds
    A_InputCreds --> JS_Val
    JS_Val -- "Invalid" --> Shake
    Shake --> A_Auth
    JS_Val -- "Valid" --> AdminDash

    %% Admin Dashboard Flow
    AdminDash --> LoadAdminStats
    LoadAdminStats --> DisplayAdminStats
    AdminDash --> TabNav

    %% Candidates Tab Flow
    TabNav -- "Candidates" --> CandFilters
    CandFilters --> LoadCandList
    LoadCandList --> DisplayCandList
    DisplayCandList --> AddCandBtn
    AddCandBtn --> ModalAdd
    ModalAdd --> InputSIC
    InputSIC --> FetchStu
    FetchStu --> ShowStuInfo
    ShowStuInfo --> InputMotivation
    InputMotivation --> SubmitCandidate
    SubmitCandidate --> RegCand
    RegCand --> DB_AddCand
    DB_AddCand --> LoadCandList
    
    DisplayCandList --> EditCandBtn
    EditCandBtn --> ModalEdit
    ModalEdit --> ShowBeforeAfter
    ShowBeforeAfter --> ConfirmUpdate
    ConfirmUpdate -- "Yes" --> UpdMot
    ConfirmUpdate -- "No" --> DisplayCandList
    UpdMot --> DB_Upd
    DB_Upd --> LoadCandList
    
    DisplayCandList --> DelCandBtn
    DelCandBtn --> ConfirmDelete
    ConfirmDelete -- "Yes" --> DelCand
    ConfirmDelete -- "No" --> DisplayCandList
    DelCand --> DB_Del
    DB_Del --> LoadCandList

    %% Import Tab Flow
    TabNav -- "Import Data" --> ImportBtn
    ImportBtn --> FileDialog
    FileDialog --> SelectFile
    SelectFile --> UploadJSP
    UploadJSP --> ParseFile
    ParseFile -- "CSV" --> ParseCSV
    ParseFile -- "XLSX" --> ParseXLSX
    ParseFile -- "XLS" --> ParseXLS
    ParseFile -- "Strict OOXML Error" --> HandleStrictOOXML
    HandleStrictOOXML --> ImportBtn
    ParseCSV --> ValidateRows
    ParseXLSX --> ValidateRows
    ParseXLS --> ValidateRows
    ValidateRows --> ValidateYear
    ValidateYear --> BatchInsert
    BatchInsert --> ShowUploadResult

    %% Results Tab Flow
    TabNav -- "Results" --> ViewResultsBtn
    ViewResultsBtn --> WinJSP
    WinJSP --> QueryMaxVotes
    QueryMaxVotes --> TieCheck
    TieCheck -- "No Tie" --> ShowWinner
    TieCheck -- "Tie Detected" --> TieModal
    TieModal --> InputCGPA
    InputCGPA --> CalcTieBreaker
    CalcTieBreaker --> DisplayTieWinner

    %% Promote Tab Flow
    TabNav -- "Promote" --> PromoteBtn
    PromoteBtn --> PromoteModal
    PromoteModal --> PromoteFilters
    PromoteFilters --> PromoteWarning
    PromoteWarning --> ConfirmPromote
    ConfirmPromote -- "Yes" --> PromoJSP
    ConfirmPromote -- "No" --> AdminDash
    PromoJSP --> DB_Promo
    DB_Promo --> ShowPromoResult

    %% Delete Tab Flow
    TabNav -- "Delete Data" --> DeleteBtn
    DeleteBtn --> DeleteModal
    DeleteModal --> DeleteFilters
    DeleteFilters --> DeleteWarning
    DeleteWarning --> TypeConfirm
    TypeConfirm --> ValidateText
    ValidateText -- "Match" --> EnableDeleteBtn
    ValidateText -- "No Match" --> TypeConfirm
    EnableDeleteBtn --> ConfirmDeleteData
    ConfirmDeleteData -- "Yes" --> DeleteJSP
    ConfirmDeleteData -- "No" --> AdminDash
    DeleteJSP --> DB_DeleteStu
    DeleteJSP --> DB_DeleteCand
    DB_DeleteStu --> ShowDeleteResult
    DB_DeleteCand --> ShowDeleteResult

    %% Reset Tab Flow
    TabNav -- "Reset" --> ResetBtn
    ResetBtn --> ResetWarning
    ResetWarning --> ConfirmReset
    ConfirmReset -- "Yes" --> ResetJSP
    ConfirmReset -- "No" --> AdminDash
    ResetJSP --> DB_ResetVotes
    ResetJSP --> DB_ClearCand
    DB_ResetVotes --> ShowResetResult
    DB_ClearCand --> ShowResetResult

    AdminDash --> LogoutAdmin
    LogoutAdmin --> Start

    %% Database Connections (Dotted Lines)
    AuthJSP -.-> T_Students
    LoadStats -.-> T_Students
    LoadStats -.-> T_Candidates
    FetchCand -.-> T_Candidates
    CastJSP -.-> T_Students
    CastJSP -.-> T_Candidates
    FetchStu -.-> T_Students
    RegCand -.-> T_Candidates
    DelCand -.-> T_Candidates
    UpdMot -.-> T_Candidates
    WinJSP -.-> T_Candidates
    PromoJSP -.-> T_Students
    DeleteJSP -.-> T_Students
    DeleteJSP -.-> T_Candidates
    ResetJSP -.-> T_Students
    ResetJSP -.-> T_Candidates
    BatchInsert -.-> T_Students
    LoadCandList -.-> T_Candidates
    LoadAdminStats -.-> T_Students
    LoadAdminStats -.-> T_Candidates
    LoadStudentData -.-> T_Students

    %% Styling
    classDef landingStyle fill:#1a1e24,stroke:#8ab452,stroke-width:3px,color:#fff
    classDef studentStyle fill:#0a0e12,stroke:#4a9eff,stroke-width:2px,color:#fff
    classDef adminStyle fill:#0a0e12,stroke:#ff6b6b,stroke-width:2px,color:#fff
    classDef dbStyle fill:#2d1b00,stroke:#ffa500,stroke-width:3px,color:#fff,stroke-dasharray:5 5
    classDef processStyle fill:#1a1e24,stroke:#8ab452,stroke-width:2px,color:#8ab452
    classDef decisionStyle fill:#2d2d00,stroke:#ffd700,stroke-width:2px,color:#ffd700
    classDef errorStyle fill:#2d0000,stroke:#ff4757,stroke-width:2px,color:#ff4757
    classDef successStyle fill:#002d00,stroke:#27ae60,stroke-width:2px,color:#27ae60
    classDef modalStyle fill:#1a1e24,stroke:#9b59b6,stroke-width:2px,color:#9b59b6

    class Start,LoadStats,DisplayStats,ChoosePortal landingStyle
    class S_Auth,S_InputSIC,VotePage,LoadStudentData,DisplayStudentInfo,LoadCand,DisplayCand,SelectCandidate,LogoutStudent studentStyle
    class A_Auth,A_InputCreds,AdminDash,LoadAdminStats,DisplayAdminStats,TabNav,LogoutAdmin adminStyle
    class T_Students,T_Candidates dbStyle
    class AuthJSP,FetchCand,CastJSP,FetchStu,RegCand,DelCand,UpdMot,WinJSP,PromoJSP,DeleteJSP,ResetJSP,UploadJSP,ParseCSV,ParseXLSX,ParseXLS,BatchInsert processStyle
    class DB_Check_Stu,Check_Voted,JS_Val,ValidateMatch,ConfirmVote,ConfirmUpdate,ConfirmDelete,TieCheck,ConfirmPromote,ValidateText,ConfirmDeleteData,ConfirmReset,ParseFile decisionStyle
    class Err_NotFound,Err_Voted,Shake,ReturnErr,CancelVote,HandleStrictOOXML errorStyle
    class CreateSession,ShowSuccess,ReturnSuccess,CommitTrans,ShowWinner,DisplayTieWinner,ShowPromoResult,ShowDeleteResult,ShowResetResult,ShowUploadResult successStyle
    class ModalAdd,ModalEdit,TieModal,PromoteModal,DeleteModal,ResetWarning,PromoteWarning,DeleteWarning modalStyle
    class CandFilters,LoadCandList,DisplayCandList,AddCandBtn,EditCandBtn,DelCandBtn,ImportBtn,FileDialog,SelectFile,ViewResultsBtn,PromoteBtn,DeleteBtn,ResetBtn,ShowBeforeAfter,InputSIC,ShowStuInfo,InputMotivation,SubmitCandidate,QueryMaxVotes,PromoteFilters,DeleteFilters,TypeConfirm,EnableDeleteBtn,ValidateRows,ValidateYear adminStyle
    class DB_AddCand,DB_Del,DB_Upd,DB_Promo,DB_DeleteStu,DB_DeleteCand,DB_ResetVotes,DB_ClearCand,StartTransaction,UpdateVoteCount,MarkVoted dbStyle
    class FilterCand,CastScript,DisplayStudentInfo studentStyle
    class Tab_Candidates,Tab_Import,Tab_Results,Tab_Promote,Tab_Delete,Tab_Reset adminStyle
