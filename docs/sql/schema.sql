-- 1) 학생 정보
CREATE TABLE student (
    id         BIGINT AUTO_INCREMENT PRIMARY KEY,
    name       VARCHAR(50) NOT NULL,
    email      VARCHAR(100) NOT NULL UNIQUE,
    track      ENUM('AI SW Basic', 'AI SW Advanced', 'AI SW Master') NOT NULL DEFAULT 'AI SW Basic',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 2) 미션 정보
CREATE TABLE mission (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    title           VARCHAR(100) NOT NULL,
    category ENUM('SERVER_OPS', 'BACKEND', 'FRONTEND','DATA', 'AI_SERVING', 'WEB_BASIC') NOT NULL,
    difficulty      TINYINT,
    estimated_hours INT,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_mission_difficulty
        CHECK (difficulty BETWEEN 1 AND 3),
    CONSTRAINT chk_mission_hours        
        CHECK (estimated_hours >= 0)
) ENGINE=InnoDB;

-- 3) 진도 관리
CREATE TABLE mission_progress (
    id           BIGINT AUTO_INCREMENT PRIMARY KEY,
    student_id   BIGINT NOT NULL,
    mission_id   BIGINT NOT NULL,
    attempt_no   TINYINT NOT NULL,
    status       ENUM('NOT_STARTED', 'IN_PROGRESS', 'DONE') NOT NULL DEFAULT 'NOT_STARTED',
    reviewed_at DATETIME,
    final_result ENUM('NOT_STARTED', 'IN_PROGRESS', 'PASS', 'FAIL') NOT NULL DEFAULT 'NOT_STARTED',
    CONSTRAINT fk_progress_student
        FOREIGN KEY (student_id) REFERENCES student(id),
    CONSTRAINT fk_progress_mission
        FOREIGN KEY (mission_id) REFERENCES mission(id),
    CONSTRAINT up_progress_student_mission_attempt_no
        UNIQUE (student_id, mission_id, attempt_no)
) ENGINE=InnoDB;

-- 4) 동료평가
CREATE TABLE peer_review (
    id                  BIGINT AUTO_INCREMENT PRIMARY KEY,
    mission_id          BIGINT NOT NULL,
    attempt_no          TINYINT NOT NULL,
    reviewer_student_id BIGINT NOT NULL,
    reviewee_student_id BIGINT NOT NULL,
    review_result       ENUM('PASS', 'FAIL') NOT NULL,
    comment             VARCHAR(500),
    reviewed_at         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_review_reviewee_progress
        FOREIGN KEY (reviewee_student_id, mission_id, attempt_no)
        REFERENCES mission_progress (student_id, mission_id, attempt_no),
    CONSTRAINT uq_peer_review_unique_pair
        UNIQUE (mission_id, attempt_no, reviewer_student_id, reviewee_student_id),
    CHECK (reviewer_student_id <> reviewee_student_id)
) ENGINE=InnoDB;
