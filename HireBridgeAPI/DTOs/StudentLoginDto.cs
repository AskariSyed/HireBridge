using HireBridgeAPI.Validation;
using System.ComponentModel.DataAnnotations;

namespace HireBridgeAPI.DTOs
{
    public class StudentLoginDto
    {
        [Required]
        public string RegistrationNumber { get; set; }
        [PasswordValidation]
        public string Password { get; set; }
        public string FCMToken { get; set; }
    }
}
