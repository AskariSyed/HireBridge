using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HireBridgeAPI.Models
{
    public class Student
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int StudentID { get; set; }

        [ForeignKey("User")]
        public int UserID { get; set; }
        public User User { get; set; }

        [Required]
        [MaxLength(15)]
        public string RegistrationNumber { get; set; } 

        [Required]
        [MaxLength(100)]
        public string Name { get; set; }

        [Required]
        [MaxLength(100)]
        public string Email { get; set; }

        [MaxLength(50)]
        public string? DegreeProgram { get; set; }  

        public decimal? GPA { get; set; }

        public string? Skills { get; set; }

        public string? Interests { get; set; }

        public string? FYPTitle { get; set; }

        public string? FYPDescription { get; set; }

        public string? CVPath { get; set; }

        public string? FCMToken { get; set; }
    }
}
