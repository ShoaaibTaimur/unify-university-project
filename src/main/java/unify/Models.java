package unify;

import java.io.Serializable;

public class Models {

    public static class User implements Serializable {
        public String id;
        public String name;
        public String email;
        public String password;
        public String role;
        public String departmentId;
        public String batchId;
        public String sectionId;

        public User() {}
        public User(String id, String name, String email, String password, String role, String departmentId, String batchId, String sectionId) {
            this.id = id;
            this.name = name;
            this.email = email;
            this.password = password;
            this.role = role;
            this.departmentId = departmentId;
            this.batchId = batchId;
            this.sectionId = sectionId;
        }

        public String getId() { return id; }
        public String getName() { return name; }
        public String getEmail() { return email; }
        public String getPassword() { return password; }
        public String getRole() { return role; }
        public String getDepartmentId() { return departmentId; }
        public String getBatchId() { return batchId; }
        public String getSectionId() { return sectionId; }
    }

    public static class Department implements Serializable {
        public String id;
        public String name;

        public Department() {}
        public Department(String id, String name) {
            this.id = id;
            this.name = name;
        }

        public String getId() { return id; }
        public String getName() { return name; }
    }

    public static class Batch implements Serializable {
        public String id;
        public String departmentId;
        public String name;

        public Batch() {}
        public Batch(String id, String departmentId, String name) {
            this.id = id;
            this.departmentId = departmentId;
            this.name = name;
        }

        public String getId() { return id; }
        public String getDepartmentId() { return departmentId; }
        public String getName() { return name; }
    }

    public static class Section implements Serializable {
        public String id;
        public String batchId;
        public String name;

        public Section() {}
        public Section(String id, String batchId, String name) {
            this.id = id;
            this.batchId = batchId;
            this.name = name;
        }

        public String getId() { return id; }
        public String getBatchId() { return batchId; }
        public String getName() { return name; }
    }

    public static class Activity implements Serializable {
        public String id;
        public String departmentId;
        public String batchId;
        public String sectionId;
        public String activityType;
        public String title;
        public String subject;
        public String room;
        public String description;
        public String eventDate;
        public String startDate;
        public String endDate;
        public String createdBy;

        public Activity() {}

        public String getId() { return id; }
        public String getDepartmentId() { return departmentId; }
        public String getBatchId() { return batchId; }
        public String getSectionId() { return sectionId; }
        public String getActivityType() { return activityType; }
        public String getTitle() { return title; }
        public String getSubject() { return subject; }
        public String getRoom() { return room; }
        public String getDescription() { return description; }
        public String getEventDate() { return eventDate; }
        public String getStartDate() { return startDate; }
        public String getEndDate() { return endDate; }
        public String getCreatedBy() { return createdBy; }
    }
}
