namespace HireBridgeAPI.Validation
{
    using System.ComponentModel.DataAnnotations;
    using System.Text.RegularExpressions;


        public class EmailValidationAttribute : ValidationAttribute
        {
            private const string EmailPattern = @"^[^@\s]+@[^@\s]+\.[^@\s]+$";

            protected override ValidationResult IsValid(object value, ValidationContext validationContext)
            {
                var email = value as string;

                if (string.IsNullOrWhiteSpace(email))
                    return new ValidationResult("Email is required.");

                if (!Regex.IsMatch(email, EmailPattern))
                    return new ValidationResult("Invalid email address format.");

                return ValidationResult.Success;
            }
        }
    

}
