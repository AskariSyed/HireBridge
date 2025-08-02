using System;
using System.Text.Json.Serialization;

namespace HireBridgeAPI.Models
{
    public class Company
    {
        public int Id { get; set; }

        public string Name { get; set; }
        public string HRContact { get; set; }
        public string Domain { get; set; }
        public int NumReps { get; set; }

        public int? AssignedRoomId { get; set; }

        [JsonIgnore]
        public Room AssignedRoom { get; set; }

        public string Username { get; set; }
        public string PasswordHash { get; set; }

        public int EstimatedInterviewDuration { get; set; }

        public string Role { get; set; } = "Company";

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
