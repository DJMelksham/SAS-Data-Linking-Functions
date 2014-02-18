PROC FCMP ENCRYPT outlib=CFUNC.DAMIENFUNCTIONS.STRINGCOMPS;
	FUNCTION DMETAPHONE(string_1 $, dmetaoption) $ 9;
		slavogermanic=0;
	alternate=0;
	length string $ 64 string_pad $ 64 pre_pad $ 64 DMPV1 $ 9 DMPV2 $ 9;
	string=TRIM(LEFT(UPCASE(string_1)));
	s_length=length(string);

	/* padding the original string so we can index past the end of the string.*/
	string_pad=TRIM(string)||'     ';
	pre_pad='      '||TRIM(string)||'     ';

	/* Searching for letters to check for slavogermanic flag */
	IF INDEX(string,'W')>0 OR INDEX(string,'K')>0 OR INDEX(string,'CZ')>0 OR INDEX(string,'WITZ')>0 THEN
		Slavogermanic=1;
	current=1;

	/* skip these when at start of word */
	IF substr(string_pad,1,2) in ('GN','KN','PN','WR','PS') then
		current=current+1;

	/* Initial 'X' is pronounced 'Z' e.g Xavier */
	else if substr(string_pad,1,1)='X' then
		do;
			DMPV1=compress(DMPV1||'S');
			DMPV2=compress(DMPV2||'S');
			current=current+1;
		end;

	loopcount=0;

	/* start of main loop */
	DO WHILE((length(trim(DMPV1))<=4 OR length(trim(DMPV2))<=4 OR current<=s_length) AND loopcount<64);
		/* just like link king guy, a counter to prevent endless loop */
		loopcount=loopcount+1;
		letter=substr(string_pad,current,1);

		IF letter in ('A','E','I','O','U','Y') AND current=1 THEN
			DO;
				DMPV1=compress(DMPV1||'A');
				DMPV2=compress(DMPV2||'A');
				current=current+1;
			END;

		/* CASE B */
		/* '-MB', E.G 'DUMB', ALREADY SKIPPED OVER */
		ELSE IF letter='B' THEN
			DO;
				DMPV1=compress(DMPV1||'P');
				DMPV2=compress(DMPV2||'P');

				IF substr(string_pad,current+1,1)='B' then
					current=current+2;
				ELSE current=current+1;
			END;
		ELSE IF letter='Ç' THEN
			DO;
				DMPV1=compress(DMPV1||'S');
				DMPV2=compress(DMPV2||'S');
				current=current+1;
			END;

		/* CASE C */
		ELSE IF letter='C' THEN
			DO;
				/* Various Germanic */
				IF (current>2 AND substr(pre_pad,current+6-2,1) NOT IN ('A','E','I','O','U','Y') 
					AND substr(pre_pad,current+6-1,3)='ACH') AND (substr(string_pad,current+2,1) NOT IN ('I','E') 
					OR substr(pre_pad,current+6-2,6) in ('BACHER','MACHER')) THEN
					DO;
						DMPV1=compress(DMPV1||'K');
						DMPV2=compress(DMPV2||'K');
						current=current+2;
					END;

				/* Special case 'Ceaser' */
				ELSE IF current=1 and substr(string_pad,current,6)='CAESAR' THEN
					do;
						DMPV1=compress(DMPV1||'S');
						DMPV2=compress(DMPV2||'S');
						current=current+2;
					end;

				/* Italian chianti */
				ELSE IF substr(string_pad,current,4)='CHIA' THEN
					DO;
						DMPV1=compress(DMPV1||'K');
						DMPV2=compress(DMPV2||'K');
						current=current+2;
					END;
				ELSE IF substr(string_pad,current,2)='CH' THEN
					DO;
						/* Find michael */
						IF current>1 and substr(string_pad,current,4)='CHAE' then
							do;
								DMPV1=compress(DMPV1||'K');
								DMPV2=compress(DMPV2||'X');
								current=current+2;
							end;

						/* Greek roots e.g 'chemistry', 'chorus' */
						ELSE IF current=1 and 
							(substr(string_pad,current+1,5) in ('HARAC','HARIS') OR substr(string_pad,current+1,3) IN ('HOR','HYM','HIA','HEM'))
							and substr(string_pad,1,5)^='CHORE' then
							do;
								DMPV1=compress(DMPV1||'K');
								DMPV2=compress(DMPV2||'K');
								current=current+2;
							end;

						/* germanic, greek, or otherwise 'ch' for 'kh' sound */
						else IF (SUBSTR(string_pad,1,4) in ('VAN ','VON ') OR SUBSTR(string_pad,1,3)='SCH') 
							OR SUBSTR(pre_pad,current+6-2,6) in ('ORCHES', 'ARCHIT', 'ORCHID') 
							OR SUBSTR(string_pad,current+2,1) in ('T','S') 
							OR (SUBSTR(pre_pad,current+6-1,1) in ('A','O','U','E') OR (current=1) AND   
							SUBSTR(string_pad,current+2,1) in ('L','R','N','M','B','H','F','V','W',' '))
							Then
							do;
								DMPV1=compress(DMPV1||'K');
								DMPV2=compress(DMPV2||'K');
							End;
						ELSE
							do;
								IF current>1 then
									do;
										IF SUBSTR(string_pad,1,2)='MC' then
											do;
												/* e.g., McHugh */
												DMPV1=compress(DMPV1||'K');
												DMPV2=compress(DMPV2||'K');
											End;
										ELSE
											do;
												DMPV1=compress(DMPV1||'X');
												DMPV2=compress(DMPV2||'K');
											END;
									end;
								ELSE
									do;
										DMPV1=compress(DMPV1||'X');
										DMPV2=compress(DMPV2||'X');
									END;
							END;

						current=current+2;
					END;

				/* e.g, czerny */
				Else IF SUBSTR(string_pad,current,2)='CZ' AND SUBSTR(pre_pad,current+6-2,4)^='WICZ' then
					do;
						DMPV1=compress(DMPV1||'S');
						DMPV2=compress(DMPV2||'X');
						current=current+2;
					END;

				/* e.g., focaccia */
				Else IF SUBSTR(string_pad,current+1,3)='CIA' then
					do;
						DMPV1=compress(DMPV1||'X');
						DMPV2=compress(DMPV2||'X');
						current=current+3;
					END;

				/* double C, but not if e.g. McClellan */
				Else IF SUBSTR(string_pad,current,2)='CC' AND NOT (current=2 AND SUBSTR(string_pad,1,1)='M') then
					do;
						/* bellocchio but not bacchus */
						IF SUBSTR(string_pad,current+2,1) in ('I','E','H') AND 
							SUBSTR(string_pad, current+2,2)^='HU' Then
							do;
								/* accident, accede succeed */
								IF((current=2) AND (SUBSTR(pre_pad,current+6-1,1)='A')) 
									OR SUBSTR(pre_pad,current+6-1,5) in ('UCCEE','UCCES') then
									do;
										DMPV1=compress(DMPV1||'KS');
										DMPV2=compress(DMPV2||'KS');

										/* bacci, bertucci, other Italian */
									End;
								ELSE
									do;
										DMPV1=compress(DMPV1||'X');
										DMPV2=compress(DMPV2||'X');
									END;

								current=current+3;
							end;
						ELSE
							do;
								DMPV1=compress(DMPV1||'K');
								DMPV2=compress(DMPV2||'K');
								current=current+2;
							END;
					END;
				Else IF SUBSTR(string_pad,current,2) in ('CK','CG','CQ') then
					do;
						DMPV1=compress(DMPV1||'K');
						DMPV2=compress(DMPV2||'K');
						current=current+2;
					END;
				Else IF SUBSTR(string_pad,current,2) in ('CI','CE','CY') then
					do;
						/* italian vs. English */
						IF SUBSTR(string_pad, current, 3) in ('CIO', 'CIE', 'CIA') then
							do;
								DMPV1=compress(DMPV1||'S');
								DMPV2=compress(DMPV2||'X');
							End;
						ELSE
							do;
								DMPV1=compress(DMPV1||'S');
								DMPV2=compress(DMPV2||'S');
							END;

						current=current+2;
					END;
				Else
					do;
						DMPV1=compress(DMPV1||'K');
						DMPV2=compress(DMPV2||'K');

						* name sent in mac caffrey, mac gregor;
						IF SUBSTR(string_pad,current+1,2) in (' C',' Q',' G') then
							do;
								current=current+3;
							end;
						ELSE
							do;
								IF SUBSTR(string_pad,current+1,1) in ('C','K','Q') 
									AND SUBSTR(string_pad, current+1, 2) not in ('CE', 'CI') THEN
									DO;
										current=current+2;
									END;
								ELSE
									DO;
										current=current+1;
									END;
							END;
					END;
			END;

		/* CASE D */
		Else If letter='D' then
			do;
				IF SUBSTR(string_pad,current,2)='DG' then
					do;
						IF SUBSTR(string_pad,current+2,1) in ('I','E','Y') then
							do;
								/* e.g. edge */
								DMPV1=compress(DMPV1||'J');
								DMPV2=compress(DMPV2||'J');
								current=current+3;
							end;
						ELSE
							do;
								/* e.g. edgar */
								DMPV1=compress(DMPV1||'TK');
								DMPV2=compress(DMPV2||'TK');
								current=current+2;
							END;
					END;
				Else IF SUBSTR(string_pad,current,2) in ('DT','DD') then
					do;
						DMPV1=compress(DMPV1||'K');
						DMPV2=compress(DMPV2||'K');
						current=current+2;
					END;
				Else
					do;
						DMPV1=compress(DMPV1||'T');
						DMPV2=compress(DMPV2||'T');
						current=current+1;
					end;
			end;

		/* CASE F */
		Else If letter='F' then
			do;
				IF SUBSTR(string_pad,current+1,1)='F' then
					current=current+2;
				ELSE current=current+1;
				DMPV1=compress(DMPV1||'F');
				DMPV2=compress(DMPV2||'F');
			End;

		/* CASE G */
		Else If letter='G' then
			do;
				IF SUBSTR(string_pad,current+1,1)='H' then
					do;
						IF (current>1) AND 
							SUBSTR(pre_pad,current+6-1,1) not in ('A','E','I','O','U','Y') then
							do;
								DMPV1=compress(DMPV1||'K');
								DMPV2=compress(DMPV2||'K');
								current=current+2;
							END;
						Else IF current < 4 then
							do;
								/* ghislane, ghiradelli */
								IF current=1 then
									do;
										IF SUBSTR(string_pad,current+2,1)='I' then
											do;
												DMPV1=compress(DMPV1||'J');
												DMPV2=compress(DMPV2||'J');
											End;
										ELSE
											do;
												DMPV1=compress(DMPV1||'K');
												DMPV2=compress(DMPV2||'K');
											End;

										current=current+2;
									END;
							END;

						/* Parkers rule (with some further refinements) - e.g., hugh
																														       e.g., bough
																														       e.g., broughton */
						Else IF ((current>2) AND SUBSTR(pre_pad,current+6-2,1) in ('B','H','D')) OR 
							((current>3) AND SUBSTR(pre_pad,current+6-3,1) in ('B','H','D')) OR 
							((current>4) AND SUBSTR(pre_pad,current+6-4,1) in ('B','H')) then
							do;
								current=current+2;
							end;
						ELSE
							do;
								* e.g., laugh, McLaughlin, cough, gough, rough, tough;
								IF (current>3) AND 
									SUBSTR(pre_pad,current+6-1,1)='U' AND 
									SUBSTR(pre_pad,current+6-3,1) in ('C','G','L','R','T') then
									do;
										DMPV1=compress(DMPV1||'F');
										DMPV2=compress(DMPV2||'F');
									End;
								ELSE
									do;
										IF (current>1) AND SUBSTR(pre_pad,current+6-1,1)^='I' then
											do;
												DMPV1=compress(DMPV1||'K');
												DMPV2=compress(DMPV2||'K');
											END;
									END;

								current=current+2;
							END;
					END;
				Else IF SUBSTR(string_pad,current+1,1)='N' then
					do;
						IF (current = 2) AND substr(string_pad,1,1) in ('A', 'E', 'I', 'O', 'U', 'Y') AND 
							SlavoGermanic=0 then
							do;
								DMPV1=compress(DMPV1||'KN');
								DMPV2=compress(DMPV2||'N');
							End;
						ELSE
							do;
								/* not e.g. cagney */
								IF SUBSTR(string_pad, current+2, 2) ^= 'EY' 
									AND (SUBSTR(string_pad,current+1,1) ^= 'Y') AND SlavoGermanic=0 then
									do;
										DMPV1=compress(DMPV1||'N');
										DMPV2=compress(DMPV2||'KN');
									End;
								ELSE
									do;
										DMPV1=compress(DMPV1||'KN');
										DMPV2=compress(DMPV2||'KN');
									END;
							END;

						current=current+2;
					END;

				/* tagliaro */
				Else IF SUBSTR(string_pad,current+1,2)='LI' AND SlavoGermanic=0 then
					do;
						DMPV1=compress(DMPV1||'KL');
						DMPV2=compress(DMPV2||'L');
						current=current+2;
					END;

				/* -ges-,-gep-,-gel-, -gie- at beginning */
				Else IF (current=1) and
					(SUBSTR(string_pad,current+1,1)='Y' OR 
					SUBSTR(string_pad,current+1,2) IN ('ES','EP','EB','EL','EY','IB','IL','IN','IE','EI','ER'))
					Then
					do;
						DMPV1=compress(DMPV1||'K');
						DMPV2=compress(DMPV2||'J');
						current=current+2;
					END;

				/* -ger-, -gy- */
				Else IF (SUBSTR(string_pad,current+1,2)='ER' OR SUBSTR(string_pad,current+1,1)='Y')
					AND SUBSTR(string_pad,1,6) not in ('DANGER','RANGER','MANGER') 
					AND SUBSTR(pre_pad,current+6-1,1) not in ('E','I') 
					AND SUBSTR(pre_pad,current+6-1,3) not in ('RGY','OGY') then
					do;
						DMPV1=compress(DMPV1||'K');
						DMPV2=compress(DMPV2||'J');
						current=current+2;
					END;

				/* italian e.g, biaggi */
				Else IF SUBSTR(string_pad,current+1,1) in ('E', 'I', 'Y') OR 
					SUBSTR(pre_pad,current+6-1,4) in ('AGGI','OGGI') then
					do;
						/* obvious Germanic */
						IF SUBSTR(string_pad,1,4) in ('VAN ', 'VON ') OR SUBSTR(string_pad,1,3)='SCH' OR 
							SUBSTR(string_pad,current+1,2)='ET' then
							do;
								DMPV1=compress(DMPV1||'K');
								DMPV2=compress(DMPV2||'K');
							End;
						ELSE
							do;
								/* always soft if french ending */
								IF SUBSTR(string_pad,current+1,4)='IER ' then
									do;
										DMPV1=compress(DMPV1||'J');
										DMPV2=compress(DMPV2||'J');
									End;
								ELSE
									do;
										DMPV1=compress(DMPV1||'J');
										DMPV2=compress(DMPV2||'K');
									END;
							END;

						current=current+2;
					END;
				Else IF SUBSTR(string_pad,current+1,1)='G' then
					do;
						current=current+2;
					end;
				ELSE
					do;
						current=current+1;
						DMPV1=compress(DMPV1||'K');
						DMPV2=compress(DMPV2||'K');
					End;
			End;

		/* CASE H */
		Else If letter='H' then
			do;
				/* only keep if first & before vowel or btw. 2 vowels */
				IF (current=1 OR 
					SUBSTR(pre_pad,current+6-1,1) in ('A', 'E', 'I', 'O', 'U', 'Y')) AND 
					substr(string_pad,current+1,1) in ('A', 'E', 'I', 'O', 'U', 'Y') then
					do;
						DMPV1=compress(DMPV1||'H');
						DMPV2=compress(DMPV2||'H');
						current=current+2;
					end;
				ELSE
					do;
						current=current+1;
					END;
			End;

		/* CASE J*/
		Else If letter='J' then
			do;
				/* obvious spanish, jose, san jacinto */
				IF SUBSTR(string_pad,current,4)='JOSE' OR SUBSTR(string_pad,1,4)='SAN ' then
					do;
						IF ((current=1) AND (SUBSTR(string_pad,current+4,1)=' ')) OR 
							SUBSTR(string_pad,1,4)='SAN ' Then
							do;
								DMPV1=compress(DMPV1||'H');
								DMPV2=compress(DMPV2||'H');
							End;
						ELSE
							do;
								DMPV1=compress(DMPV1||'J');
								DMPV2=compress(DMPV2||'H');
							END;

						current=current+1;
					END;
				Else IF (current=1) AND SUBSTR(string_pad,current,4)^='JOSE' then
					do;
						DMPV1=compress(DMPV1||'J');
						DMPV2=compress(DMPV2||'A');
					End;
				ELSE
					do;
						/* spanish pron. of e.g. bajador */
						IF SUBSTR(pre_pad,current+6-1,1) IN ('A','E','I','O','U','Y') AND 
							SlavoGermanic=0 AND 
							((SUBSTR(string_pad,current+1,1)='A') OR (SUBSTR(string_pad,current+1,1)='O')) then
							do;
								DMPV1=compress(DMPV1||'J');
								DMPV2=compress(DMPV2||'H');
							End;
						ELSE
							do;
								IF current=s_length then
									do;
										DMPV1=compress(DMPV1||'J');
										DMPV2=compress(DMPV2||'J');
									End;
								ELSE
									do;
										IF SUBSTR(string_pad,current+1,1) not in ('L','T','K','S','N','M','B','Z')           
											AND SUBSTR(pre_pad,current+6-1,1) not in ('S','K','L') then
											do;
												DMPV1=compress(DMPV1||'J');
												DMPV2=compress(DMPV2||'J');
											END;
									END;
							END;
					END;

				IF SUBSTR(string_pad,current+1,1)='J' then
					do;
						current=current+2;
					end;
				ELSE
					do;
						current=current+1;
					END;
			End;

		/* CASE K */
		Else If letter='K' then
			do;
				IF SUBSTR(string_pad,current+1,1)='K' then
					current=current+2;
				ELSE current=current+1;
				DMPV1=compress(DMPV1||'K');
				DMPV2=compress(DMPV2||'K');
			End;

		/* CASE L */
		Else If letter='L' then
			do;
				IF SUBSTR(string_pad,current+1,1)='L' then
					do;
						/* spanish e.g. cabrillo, gallegos */
						IF (current=(s_length-2) AND 
							SUBSTR(pre_pad,current+6-1,4) in ('ILLO','ILLA','ALLE')) 
							OR 
							(current>1 AND (SUBSTR(string_pad,s_length-1, 2) in ('AS', 'OS') OR 
							SUBSTR(string_pad,s_length,1) in ('A','O')) AND 
							SUBSTR(pre_pad,current+6-1,4)='ALLE') Then
							do;
								DMPV1=compress(DMPV1||'L');
								DMPV2=compress(DMPV2||'L');
								current=current+2;
							end;
						else
							do;
								current=current+2;
							end;
					end;
				ELSE
					do;
						DMPV1=compress(DMPV1||'L');
						DMPV2=compress(DMPV2||'L');
						current=current+1;
					end;
			end;

		/* CASE M */
		Else If letter='M' then
			do;
				* dumb,thumb;
				IF SUBSTR(pre_pad,current+6-1,3)='UMB' AND 
					(current+1=s_length OR SUBSTR(string_pad,current+2,2)='ER') 
					OR SUBSTR(string_pad,current+1,1)='M' then
					current=current+2;
				ELSE current=current+1;
				DMPV1=compress(DMPV1||'M');
				DMPV2=compress(DMPV2||'M');
			end;

		/* CASE N */
		Else If letter='N' then
			do;
				IF SUBSTR(string_pad,current+1,1)='N' then
					current=current+2;
				ELSE current=current+1;
				DMPV1=compress(DMPV1||'N');
				DMPV2=compress(DMPV2||'N');
			end;
		Else If letter='Ñ' then
			do;
				current=current+1;
				DMPV1=compress(DMPV1||'N');
				DMPV2=compress(DMPV2||'N');
			end;

		/* CASE P */
		Else If letter='P' then
			do;
				IF SUBSTR(string_pad,current+1,1)='H' then
					do;
						DMPV1=compress(DMPV1||'F');
						DMPV2=compress(DMPV2||'F');
						current=current+2;
					END;

				/* also account for campbell, raspberry */
				Else
					do;
						IF SUBSTR(string_pad, current+1, 1) in ('P', 'B') then
							current=current+2;
						ELSE current=current+1;
						DMPV1=compress(DMPV1||'P');
						DMPV2=compress(DMPV2||'P');
					END;
			End;

		/* CASE Q */
		Else If letter='Q' then
			do;
				IF SUBSTR(string_pad,current+1,1)='Q' then
					current=current+2;
				ELSE current=current+1;
				DMPV1=compress(DMPV1||'K');
				DMPV2=compress(DMPV2||'K');
			end;

		/* CASE R */
		Else If letter='R' then
			do;
				/* french e.g. rogier, but exclude hochmeier */
				IF (current=s_length) AND SlavoGermanic=0 
					AND SUBSTR(pre_pad,current+6-2,2)='IE' 
					AND SUBSTR(pre_pad,current+6-4,2) not in ('ME', 'MA') then
					do;
						DMPV2=compress(DMPV2||'R');
					End;
				ELSE
					do;
						DMPV1=compress(DMPV1||'R');
						DMPV2=compress(DMPV2||'R');
					END;

				IF SUBSTR(string_pad,current+1,1)='R' then
					current=current+2;
				ELSE current=current+1;
			End;

		/* CASE S */
		Else If letter='S' then
			do;
				/* special cases island, isle, carlisle, carlysle */
				IF SUBSTR(pre_pad,current+6-1,3) in ('ISL','YSL') then
					do;
						current=current+1;
					END;

				/* special case sugar */;
				IF (current=1) AND SUBSTR(string_pad,current,5)='SUGAR' then
					do;
						DMPV1=compress(DMPV1||'X');
						DMPV2=compress(DMPV2||'S');
						current=current+1;
					END;
				Else IF SUBSTR(string_pad,current,2)='SH' then
					do;
						/* Germanic */
						IF SUBSTR(string_pad, current+1, 4) in ('HEIM', 'HOEK', 'HOLM', 'HOLZ') then
							do;
								DMPV1=compress(DMPV1||'S');
								DMPV2=compress(DMPV2||'S');
							End;
						ELSE
							do;
								DMPV1=compress(DMPV1||'X');
								DMPV2=compress(DMPV2||'X');
							END;

						current=current+2;
					END;

				/* italian & Armenian */
				Else IF SUBSTR(string_pad,current,3) in ('SIO','SIA') OR SUBSTR(string_pad,current,4)='SIAN' Then
					do;
						IF SlavoGermanic=0 then
							do;
								DMPV1=compress(DMPV1||'S');
								DMPV2=compress(DMPV2||'X');
							End;
						ELSE
							do;
								DMPV1=compress(DMPV1||'S');
								DMPV2=compress(DMPV2||'S');
							END;

						current=current+3;
					END;

				/* german & anglicisations, e.g. smith match schmidt, snider match schneider;
						   also, -sz- in slavic language altho in hungarian it is pronounced s; */
				Else IF current=1 AND 
					(SUBSTR(string_pad,current+1,1) in ('M','N','L','W') 
					OR SUBSTR(string_pad,current+1,1)='Z') then
					do;
						DMPV1=compress(DMPV1||'S');
						DMPV2=compress(DMPV2||'X');

						IF SUBSTR(string_pad,current+1,1)='Z' then
							current=current+2;
						ELSE current=current+1;
					END;
				Else IF SUBSTR(string_pad,current,2)='SC' then
					do;
						/* Schlesingers rule */
						IF SUBSTR(string_pad,current+2,1)='H' then
							do;
								/* dutch origin, e.g. school, schooner */
								IF SUBSTR(string_pad,current+3,2) in ('OO','ER','EN','UY','ED','EM') then
									do;
										/* schermerhorn, schenker */
										IF SUBSTR(string_pad, current+3,2) in ('ER','EN') then
											do;
												DMPV1=compress(DMPV1||'X');
												DMPV2=compress(DMPV2||'SK');
											End;
										ELSE
											do;
												DMPV1=compress(DMPV1||'SK');
												DMPV2=compress(DMPV2||'SK');
											End;

										current=current+3;
									end;
								ELSE
									do;
										IF (current=1) AND SUBSTR(string_pad,3,1) not in ('A','E','I','O','U','Y') AND 
											SUBSTR(string_pad,3,1)^='W' then
											do;
												DMPV1=compress(DMPV1||'X');
												DMPV2=compress(DMPV2||'S');
											End;
										ELSE
											do;
												DMPV1=compress(DMPV1||'X');
												DMPV2=compress(DMPV2||'X');
											END;

										current=current+3;
									END;
							END;
						Else IF SUBSTR(string_pad,current+2,1) in ('I', 'E', 'Y') then
							do;
								DMPV1=compress(DMPV1||'S');
								DMPV2=compress(DMPV2||'S');
								current=current+3;
							END;
						Else
							do;
								DMPV1=compress(DMPV1||'SK');
								DMPV2=compress(DMPV2||'SK');
								current=current+3;
							end;
					END;

				/* french e.g. resnais, artois */
				Else IF (current=s_length) and SUBSTR(pre_pad,current+6-2,2) in ('AI','OI') then
					do;
						DMPV2=compress(DMPV2||'S');
						current=current+1;
					end;
				ELSE
					do;
						DMPV1=compress(DMPV1||'S');
						DMPV2=compress(DMPV2||'S');

						IF SUBSTR(string_pad,current+1,1) in ('S','Z') then
							current=current+2;
						ELSE current=current+1;
					End;
			End;

		/* CASE T */
		Else If letter='T' then
			do;
				IF SUBSTR(string_pad,current,4)='TION' then
					do;
						DMPV1=compress(DMPV1||'X');
						DMPV2=compress(DMPV2||'X');
						current=current+3;
					END;
				Else IF SUBSTR(string_pad,current,3) in ('TIA','TCH') then
					do;
						DMPV1=compress(DMPV1||'X');
						DMPV2=compress(DMPV2||'X');
						current=current+3;
					END;
				Else IF SUBSTR(string_pad,current,2)='TH' OR SUBSTR(string_pad,current,3)='TTH' then
					do;
						/* special case thomas, thames or Germanic */
						IF SUBSTR(string_pad,current+2,2) in ('OM','AM') OR 
							SUBSTR(string_pad,1,4) in ('VAN ','VON ') OR 
							SUBSTR(string_pad,1,3)='SCH' then
							do;
								DMPV1=compress(DMPV1||'T');
								DMPV2=compress(DMPV2||'T');
							End;
						ELSE
							do;
								DMPV1=compress(DMPV1||'0');
								DMPV2=compress(DMPV2||'T');
							END;

						current=current+2;
					END;
				Else
					do;
						IF SUBSTR(string_pad,current+1,1) in ('T','D') then
							current=current+2;
						ELSE current=current+1;
						DMPV1=compress(DMPV1||'T');
						DMPV2=compress(DMPV2||'T');
					END;
			End;

		/* CASE V */
			Else If letter='V' then do;
    IF SUBSTR(string_pad,current+1,1)='V' then current=current+2;
    ELSE current=current+1;
    DMPV1=compress(DMPV1||'F');
		DMPV2=compress(DMPV2||'F');
  End;

  /* CASE W */
Else If letter='W' then do;
    /* can also be in middle of word */
    IF SUBSTR(string_pad,current,2)='WR' then do;
      DMPV1=compress(DMPV1||'R');
		DMPV2=compress(DMPV2||'R');
      current=current+2;
    END;

    Else IF (current=1) AND 
       (SUBSTR(string_pad,current+1,1) in ('A', 'E', 'I', 'O', 'U', 'Y') OR 
       SUBSTR(string_pad, current, 2)='WH') then do;

       /* Wasserman should match Vasserman */
        IF SUBSTR(string_pad,current+1,1) in ('A', 'E', 'I', 'O', 'U', 'Y') then do;
          DMPV1=compress(DMPV1||'A');
		DMPV2=compress(DMPV2||'F');
        End;
        ELSE do;
        /* need Uomo to match Womo */
          DMPV1=compress(DMPV1||'A');
		DMPV2=compress(DMPV2||'A');
        End;
        current=current+1;
    END;
    /* Arnow should match Arnoff */
    Else IF (current=s_length AND
             SUBSTR(pre_pad,current+6-1,1) in ('A', 'E', 'I', 'O', 'U', 'Y')) OR
            SUBSTR(pre_pad,current+6-1,5) in ('EWSKI','EWSKY','OWSKI','OWSKY') OR
            SUBSTR(string_pad,1,3)='SCH' then do;
		DMPV2=compress(DMPV2||'F');
      current=current+1;
    END;
    /* polish e.g. filipowicz */
    Else IF SUBSTR(string_pad,current,4)in ('WICZ', 'WITZ') then do;
      DMPV1=compress(DMPV1||'TS');
		DMPV2=compress(DMPV2||'FX');
      current=current+4;
    END;
    Else do;
    /* else skip it */
    current=current+1;
    end;
  end;
/* CASE X */
 else If letter='X' then do;
    /* french e.g. breaux; */
    IF (current^=s_length and 
      SUBSTR(pre_pad,current+6-3,3) not in ('IAU', 'EAU') AND
      SUBSTR(pre_pad,current+6-2,2) not in ('AU', 'OU')) then do;
      DMPV1=compress(DMPV1||'KS');
		DMPV2=compress(DMPV2||'KS');
    END;
    IF SUBSTR(string_pad, current+1, 1) in ('C', 'X') then current=current+2;
    ELSE current=current+1;
  End;
/* CASE Z */
 Else If letter='Z' then do;
    /* chinese pinyin e.g. zhao; */
    IF SUBSTR(string_pad,current+1,1)='H' then do;
      DMPV1=compress(DMPV1||'J');
		DMPV2=compress(DMPV2||'J');
      current=current+2;
    end;
    ELSE do;
     IF SUBSTR(string_pad,current+1,2) in ('ZO','ZI','ZA') OR 
       (SlavoGermanic=1 AND current>1 AND SUBSTR(pre_pad,current+6-1,1) ne 'T') 
        then do;
        DMPV1=compress(DMPV1||'S');
		DMPV2=compress(DMPV2||'TS');
     end;
     ELSE do;
        DMPV1=compress(DMPV1||'S');
		DMPV2=compress(DMPV2||'S');
     end;
      IF SUBSTR(string_pad,current+1,1)='Z' then current=current+2;
      ELSE current=current+1;
	END;
  END;
/* OTHERWISE DEFAULT RESPONSE */
  ELSE CURRENT=current+1;
	END;

	/* end of main loop */
	IF length(trim(DMPV1))>4 THEN
		DMPV1=substr(DMPV1,1,4);

	IF length(trim(DMPV2))>4 THEN
		DMPV2=substr(DMPV2,1,4);

		if dmetaoption=1 then
			return(DMPV1);
		else if dmetaoption=2 then
			return(DMPV2);
		else return(trim(DMPV1)||','||trim(DMPV2));
	endsub;
run;