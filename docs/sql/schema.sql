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
    category        VARCHAR(50),
    difficulty      VARCHAR(20),
    estimated_hours INT,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 3) 진도 관리
CREATE TABLE mission_progress (
    id           BIGINT AUTO_INCREMENT PRIMARY KEY,
    student_id   BIGINT NOT NULL,
    mission_id   BIGINT NOT NULL,
    status       ENUM('NOT_STARTED', 'IN_PROGRESS', 'SUBMITTED', 'DONE') NOT NULL DEFAULT 'NOT_STARTED',
    submitted_at DATETIME,
    updated_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    final_result ENUM('PENDING', 'PASS', 'FAIL') NOT NULL DEFAULT 'PENDING',
    CONSTRAINT fk_progress_student
        FOREIGN KEY (student_id) REFERENCES student(id),
    CONSTRAINT fk_progress_mission
        FOREIGN KEY (mission_id) REFERENCES mission(id),
    CONSTRAINT uq_progress_student_mission
        UNIQUE (student_id, mission_id)
) ENGINE=InnoDB;

-- 4) 동료평가
CREATE TABLE peer_review (
    id                  BIGINT AUTO_INCREMENT PRIMARY KEY,
    mission_id          BIGINT NOT NULL,
    reviewer_student_id BIGINT NOT NULL,
    reviewee_student_id BIGINT NOT NULL,
    review_result       ENUM('PASS', 'FAIL') NOT NULL,
    comment             VARCHAR(500),
    reviewed_at         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_review_mission
        FOREIGN KEY (mission_id) REFERENCES mission(id),
    CONSTRAINT fk_review_reviewer
        FOREIGN KEY (reviewer_student_id) REFERENCES student(id),
    CONSTRAINT fk_review_reviewee
        FOREIGN KEY (reviewee_student_id) REFERENCES student(id),
    CONSTRAINT uq_peer_review_unique_pair
        UNIQUE (mission_id, reviewer_student_id, reviewee_student_id)
) ENGINE=InnoDB;
